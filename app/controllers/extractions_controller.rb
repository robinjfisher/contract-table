class ExtractionsController < ApplicationController
  before_action :set_project

  def show
    @extraction = Extraction.joins(contract: :project)
                            .where(projects: { id: @project.id })
                            .includes(:field, contract: :project)
                            .find(params[:id])
  end

  def update
    @extraction = Extraction.joins(contract: :project)
                            .where(projects: { id: @project.id })
                            .find(params[:id])

    attrs = {}
    if params[:extraction]&.key?("value")
      attrs[:value] = params.dig(:extraction, :value)&.strip
      attrs[:manually_edited] = true
    end
    if params[:extraction]&.key?("annotation")
      attrs[:annotation] = params.dig(:extraction, :annotation)&.strip.presence
    end
    @extraction.update!(attrs)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "extraction_#{@extraction.contract_id}_#{@extraction.field_id}",
          partial: "extractions/cell",
          locals: { extraction: @extraction, project_id: @project.id }
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
