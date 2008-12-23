class Spec < ActiveRecord::Base
  belongs_to :project
  indexes_columns :body, :using => :ferret
end
