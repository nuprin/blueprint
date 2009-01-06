class Initiative < ActiveRecord::Base
  set_table_name :projects

  has_many :tasks, :foreign_key => :project_id

  has_many :deliverables,
    :foreign_key => :project_id,
    :class_name => "Task",
    :conditions => {:type => "Deliverable"}

  named_scope :active,   :conditions => {:status => "active"}
  named_scope :inactive, :conditions => "status != 'active'"

  def prioritized_deliverables_by_day
    deliverables = self.deliverables.prioritized_or_completed_recently
    deliverables.group_by(&:due_date).sort_by do |date, tasks|
      # If a task has no due date, stick it at the end of the sorted lists.
      date || (Date.today + 2.weeks)
    end
  end
  
  def assignees
    self.tasks.currently_due.map(&:assignee).compact.uniq
  end
end
