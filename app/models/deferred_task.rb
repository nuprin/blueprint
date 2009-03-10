class DeferredTask < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User'
  belongs_to :task

  validates_presence_of :creator_id
  validates_presence_of :prioritize_at
  validates_presence_of :task_id

  def self.process_all
    conditions = {:prioritize_at => 1.year.ago..Time.now.getutc}
    self.all(:conditions => conditions).map(&:process)
  end
  
  def process
    self.task.prioritize!
    self.task.mass_mailer.deliver_task_reprioritized
    self.destroy    
  end
  
  def friendly_prioritize_at
    self.prioritize_at.getlocal.strftime("%b %e at %I:%M%p")
  end
  
  after_create :park_task

  def park_task
    self.task.park!
  end
  
  after_create do |deferred_task|
    deferred_task.task.mass_mailer.ignoring(deferred_task.creator).
      deliver_task_deferred(deferred_task)
  end  
end
