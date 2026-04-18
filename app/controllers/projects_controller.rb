class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(:contracts).all.order(:name)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      Field.create_predefined_for!(@project)
      redirect_to @project
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.find(params[:id])
    @contracts = @project.contracts.includes(:extractions)
    @fields = @project.fields

    @sort_field  = params[:sort_field].to_i
    @sort_dir    = params[:sort_dir] == "desc" ? "desc" : "asc"
    @filter_field = params[:filter_field].to_i
    @filter_value = params[:filter_value]

    if params[:sort_field].present?
      dir = @sort_dir == "desc" ? "DESC" : "ASC"
      @contracts = @contracts
        .joins("LEFT JOIN extractions sort_ext ON sort_ext.contract_id = contracts.id
                AND sort_ext.field_id = #{@sort_field}")
        .order(Arel.sql("sort_ext.value #{dir} NULLS LAST"))
    else
      @contracts = @contracts.order(:name)
    end

    if params[:filter_field].present? && params[:filter_value].present?
      term = "%#{@filter_value}%"
      @contracts = @contracts
        .joins("INNER JOIN extractions filter_ext ON filter_ext.contract_id = contracts.id
                AND filter_ext.field_id = #{@filter_field}")
        .where("filter_ext.value LIKE ?", term)
    end
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
