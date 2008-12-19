class InfoController < ApplicationController

  def revision
    render :text => APP_REVISION
  end

end
