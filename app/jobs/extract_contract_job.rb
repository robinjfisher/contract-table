class ExtractContractJob < ApplicationJob
  queue_as :default

  def perform(contract_id)
    contract = Contract.find(contract_id)
    fields   = contract.project.fields.to_a

    if fields.empty?
      contract.update!(status: :done)
      broadcast_contract(contract)
      return
    end

    contract.update!(status: :processing)
    broadcast_contract(contract)

    Rails.logger.info "ExtractContractJob: extracting #{fields.size} field(s) for contract=#{contract_id}"
    results = AnthropicClient.new.extract_all(contract: contract, fields: fields)

    fields.each do |field|
      result = results[field.id] || { value: nil, source_text: nil, source_page: nil }
      Rails.logger.info "ExtractContractJob: field=#{field.label} value=#{result[:value].inspect}"

      extraction = Extraction.find_or_initialize_by(contract: contract, field: field)
      extraction.update!(
        value:       result[:value],
        source_text: result[:source_text],
        source_page: result[:source_page]
      )
      broadcast_cell(contract, field, extraction)
    end

    contract.update!(status: :done)
    broadcast_status(contract)

  rescue => e
    Rails.logger.error <<~MSG
      ExtractContractJob failed contract=#{contract_id}
      #{e.class}: #{e.message}
      #{e.backtrace.first(10).join("\n")}
    MSG

    contract&.update!(status: :error)
    broadcast_status(contract) if contract
  end

  private

  def broadcast_cell(contract, field, extraction)
    Turbo::StreamsChannel.broadcast_replace_to(
      "project_#{contract.project_id}",
      target: "extraction_#{contract.id}_#{field.id}",
      partial: "extractions/cell",
      locals: { extraction: extraction }
    )
  end

  # Full row replace — used only at the start when switching to :processing,
  # so all cells render as spinners.
  def broadcast_contract(contract)
    Turbo::StreamsChannel.broadcast_replace_to(
      "project_#{contract.project_id}",
      target: "contract_#{contract.id}",
      partial: "contracts/contract",
      locals: { contract: contract, fields: contract.project.fields }
    )
  end

  # Status frame only — used at the end so we don't overwrite cell updates.
  def broadcast_status(contract)
    Turbo::StreamsChannel.broadcast_replace_to(
      "project_#{contract.project_id}",
      target: "contract_status_#{contract.id}",
      partial: "contracts/status_frame",
      locals: { contract: contract }
    )
  end
end
