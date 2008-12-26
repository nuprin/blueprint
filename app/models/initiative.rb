class Initiative < ActiveRecord::Base
  set_table_name :projects

  has_many :tasks, :foreign_key => :project_id

  named_scope :active,   :conditions => {:status => "active"}
  named_scope :inactive, :conditions => "status != 'active'"

  def deliverables_by_day
    self.tasks.currently_due.group_by(&:due_date).sort_by do |date, tasks|
      date
    end
  end
  
  def assignees
    self.tasks.currently_due.map(&:assignee).compact.uniq
  end
end
