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
    @contracts = @project.contracts.includes(:extractions).order(:name)
    @fields = @project.fields
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
