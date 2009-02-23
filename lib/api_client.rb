require 'rubygems'
require 'activeresource'

class Task < ActiveResource::Base
  self.site = "http://blueprint-api-client:callipygian@blueprint/api/"

  def complete!
    self.put(:mark_complete)
  end

end
