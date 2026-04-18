class ContractsController < ApplicationController
  ALLOWED_CONTENT_TYPES = %w[
    application/pdf
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  before_action :set_project

  def create
    @fields = @project.fields
    uploaded_files = Array(params.dig(:contracts, :files)).select { |f| f.respond_to?(:content_type) }
    @contracts = []
    @errors = []

    uploaded_files.each do |file|
      unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
        @errors << "#{file.original_filename}: unsupported file type (PDF or DOCX only)"
        next
      end

      contract = @project.contracts.build(name: file.original_filename, status: :pending)
      contract.file.attach(file)

      if contract.save
        @contracts << contract
        ExtractContractJob.perform_later(contract.id)
      else
        @errors << "#{file.original_filename}: #{contract.errors.full_messages.join(', ')}"
      end
    end

    respond_to do |format|
      format.turbo_stream do
        streams = @contracts.map do |contract|
          turbo_stream.append("contracts", partial: "contracts/contract", locals: { contract: contract, fields: @fields })
        end
        streams << turbo_stream.remove("contracts-empty-state") if @contracts.any?
        streams << turbo_stream.replace("upload-errors", partial: "contracts/errors", locals: { errors: @errors })
        render turbo_stream: streams
      end
      format.html { redirect_to @project }
    end
  end

  def show
    @contract = @project.contracts.find(params[:id])
  end

  def review
    @contract = @project.contracts.find(params[:id])
    @contract.update!(
      reviewed: !@contract.reviewed,
      reviewed_at: @contract.reviewed ? nil : Time.current
    )
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "contract_#{@contract.id}_review",
            partial: "contracts/review_button",
            locals: { contract: @contract }
          ),
          turbo_stream.replace(
            "review-progress",
            partial: "contracts/review_progress",
            locals: { project: @project }
          )
        ]
      end
      format.html { redirect_to @project }
    end
  end

  def rerun
    @contract = @project.contracts.find(params[:id])
    @contract.extractions.destroy_all
    @contract.update!(status: :pending)
    ExtractContractJob.perform_later(@contract.id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "contract_#{@contract.id}",
          partial: "contracts/contract",
          locals: { contract: @contract, fields: @project.fields }
        )
      end
      format.html { redirect_to @project }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
