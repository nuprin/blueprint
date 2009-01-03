class FeaturesController < ApplicationController
  layout "blueprint"

  # GET /features
  def index
    @features = Feature.find(:all)
  end

  def edit
    @feature = Feature.find(params[:id])
  end

  def update
    @feature = Feature.find(params[:id])
    @feature.update_attributes(params[:feature])
    redirect_to features_path
  end

  # POST /features
  def create
    @feature = Feature.new(params[:feature])

    if @feature.save
      flash[:notice] = 'Feature was successfully created.'
      redirect_to features_path
    else
      render :action => "new"
    end
  end

  # DELETE /features/1
  def destroy
    @feature = Feature.find(params[:id])
    @feature.destroy
    redirect_to(features_url)
  end
end
