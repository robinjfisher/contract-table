class ExportsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @contracts = @project.contracts.includes(:extractions).order(:name)
    @fields = @project.fields

    respond_to do |format|
      format.csv do
        send_data build_csv, filename: "#{@project.name}-contracts.csv",
                             type: "text/csv; charset=utf-8"
      end
      format.xlsx do
        response.headers["Content-Disposition"] =
          "attachment; filename=\"#{@project.name}-contracts.xlsx\""
      end
    end
  end

  private

  def build_csv
    require "csv"

    bom = "\xEF\xBB\xBF"
    bom + CSV.generate(encoding: "UTF-8") do |csv|
      csv << [ "File" ] + @fields.map(&:label)

      @contracts.each do |contract|
        row = [ contract.name ]
        @fields.each do |field|
          extraction = contract.extractions.find { |e| e.field_id == field.id }
          row << extraction&.value
        end
        csv << row
      end
    end
  end
end
