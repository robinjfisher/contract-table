class FieldsController < ApplicationController
  before_action :set_project

  def create
    if params.dig(:field, :predefined_key).present?
      template = Field::PREDEFINED_FIELDS.find { |f| f[:predefined_key] == params[:field][:predefined_key] }
      return head(:unprocessable_entity) unless template

      @field = @project.fields.build(
        label: template[:label],
        question: template[:question],
        predefined_key: template[:predefined_key],
        field_type: template.fetch(:field_type, "text"),
        position: next_position
      )
    else
      @field = @project.fields.build(field_params.merge(position: next_position))
    end

    if @field.save
      @project.contracts.each { |c| ExtractFieldJob.perform_later(c.id, @field.id) }
      respond_with_update
    else
      respond_with_update(errors: @field.errors.full_messages)
    end
  end

  def destroy
    @field = @project.fields.find(params[:id])
    @field.destroy
    respond_with_update
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def field_params
    params.require(:field).permit(:label, :question, :field_type)
  end

  def next_position
    (@project.fields.maximum(:position) || 0) + 1
  end

  def respond_with_update(errors: [])
    @fields = @project.fields.reload
    @contracts = @project.contracts.includes(:extractions).order(:name)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "contracts-table",
          partial: "projects/table",
          locals: { project: @project, fields: @fields, contracts: @contracts }
        )
      end
      format.html { redirect_to @project }
    end
  end
end
