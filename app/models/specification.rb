class Specification < ActiveRecord::Base
  belongs_to :project
  indexes_columns :body, :using => :ferret

  def to_s
    body
  end
end
