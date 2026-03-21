class ExtractFieldJob < ApplicationJob
  queue_as :default

  def perform(contract_id, field_id, attempt = 1)
    contract = Contract.find(contract_id)
    field    = Field.find(field_id)

    Rails.logger.info "ExtractFieldJob: calling Claude for contract=#{contract_id} field=#{field.predefined_key || field.label}"
    result = AnthropicClient.new.extract(contract: contract, field: field)
    Rails.logger.info "ExtractFieldJob: got result value=#{result[:value].inspect}"

    extraction = Extraction.find_or_initialize_by(contract: contract, field: field)
    extraction.update!(
      value:       result[:value],
      source_text: result[:source_text],
      source_page: result[:source_page]
    )

    broadcast_cell(contract, field, extraction)
    complete_contract_if_done(contract)

  rescue => e
    Rails.logger.error <<~MSG
      ExtractFieldJob failed (attempt #{attempt}) contract=#{contract_id} field=#{field_id}
      #{e.class}: #{e.message}
      #{e.backtrace.first(10).join("\n")}
    MSG

    if attempt < 2
      self.class.perform_later(contract_id, field_id, attempt + 1)
    else
      mark_error(contract_id, field_id)
    end
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

  def broadcast_contract(contract)
    Turbo::StreamsChannel.broadcast_replace_to(
      "project_#{contract.project_id}",
      target: "contract_status_#{contract.id}",
      partial: "contracts/status_frame",
      locals: { contract: contract }
    )
  end

  def complete_contract_if_done(contract)
    contract.reload
    return unless contract.processing?

    field_count      = contract.project.fields.count
    extraction_count = contract.extractions.count

    if extraction_count >= field_count && field_count > 0
      contract.update!(status: :done)
      broadcast_contract(contract)
    end
  end

  def mark_error(contract_id, field_id)
    contract = Contract.find_by(id: contract_id)
    field    = Field.find_by(id: field_id)
    return unless contract && field

    extraction = Extraction.find_or_initialize_by(contract: contract, field: field)
    extraction.update!(value: nil, source_text: nil, source_page: nil)

    broadcast_cell(contract, field, extraction)

    contract.update!(status: :error)
    broadcast_contract(contract)
  end
end
