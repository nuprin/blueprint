class DeferredTask < ActiveRecord::Base
  belongs_to :task

  def self.process_all
    conditions = {:prioritize_at => 1.year.ago..Time.now.getutc}
    self.all(:conditions => conditions).map(&:process)
  end
  
  def process
    self.task.prioritize!
    self.destroy    
  end
end
