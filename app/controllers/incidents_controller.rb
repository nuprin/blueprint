class IncidentsController < ApplicationController
  layout 'blueprint'
  def index
    @incidents = Incident.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @incidents }
    end
  end

  def show
    @incident = Incident.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @incident }
    end
  end

  def new
    @incident = Incident.new
  end

  def edit
    @incident = Incident.find(params[:id])
  end

  def create
    @incident = Incident.new(params[:incident])

    if @incident.save
      flash[:notice] = 'Incident was successfully created.'
      redirect_to(@incident)
    else
      render :action => "new"
    end
  end

  def update
    @incident = Incident.find(params[:id])

    respond_to do |format|
      if @incident.update_attributes(params[:incident])
        flash[:notice] = 'Incident was successfully updated.'
        format.html { redirect_to(@incident) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @incident.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @incident = Incident.find(params[:id])
    @incident.destroy

    respond_to do |format|
      format.html { redirect_to(incidents_url) }
      format.xml  { head :ok }
    end
  end
end
