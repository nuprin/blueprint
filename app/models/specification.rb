class Specification < ActiveRecord::Base
  belongs_to :project

  def to_s
    body
  end
end
