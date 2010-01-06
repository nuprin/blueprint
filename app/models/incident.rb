class Incident < ActiveRecord::Base
  def self.count_today
    self.count(:conditions => {
      :created_at => Time.now.at_midnight.getutc..Time.now.getutc
    })
  end

  def self.next_incident_number
    self.count_today + 1
  end

  def tag
    self.started_at.strftime("%Y-%m-%d-00#{self.class.next_incident_number}")
  end
  
  after_create do |incident|
    IncidentMailer.deliver_new_incident(incident)
  end
end
