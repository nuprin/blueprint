class DeferredTask < ActiveRecord::Base
  belongs_to :task

  validates_presence_of :prioritize_at
  validates_presence_of :task_id

  def self.process_all
    conditions = {:prioritize_at => 1.year.ago..Time.now.getutc}
    self.all(:conditions => conditions).map(&:process)
  end
  
  def process
    self.task.prioritize!
    self.destroy    
  end
  
  after_create :park_task
  
  def park_task
    self.task.park!
  end
end
