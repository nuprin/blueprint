class GitController < ApplicationController
  def show
    redirect_to "http://git/causes/commit?id=#{params[:id]}"
  end
end
