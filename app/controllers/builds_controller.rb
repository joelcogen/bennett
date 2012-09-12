class BuildsController < ApplicationController
  load_and_authorize_resource except: :create

  def create
    @project = Project.find(params[:project_id])
    @branch  = @project.branches.find_by_name(params[:branch])
    @build   = @branch.builds.new(params[:build])
    from_hook = params[:t].present?

    if from_hook
      raise CanCan::AccessDenied unless @project.hook_token == params[:t]
      @build.fill_from_hook(params)
    else
      authorize! :create, @build
    end

    respond_to do |format|
      if @build.save
        Resque.enqueue(Builder, @build.id)
        format.html { redirect_to @project, notice: 'Build successfully added to queue.' }
        format.json { render json: @build, status: :created }
      else
        format.html { redirect_to @project, notice: 'Error adding build.' }
        format.json { render json: @build.errors, status: :unprocessable_entity }
        # TODO Log this if coming from hook
      end
    end
  end

  def destroy
    @build = Build.find(params[:id])
    @build.delete_jobs_in_queues
    if @build.destroy
      flash[:notice] = "Build successfully deleted."
      redirect_to project_path(@build.project)
    else
      flash[:error] = "Error deleting build."
      redirect_to project_path(@build.project)
    end
  end
end
