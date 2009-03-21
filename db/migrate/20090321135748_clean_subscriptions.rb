class CleanSubscriptions < ActiveRecord::Migration
  def self.up
    conditions = {:entity_type => ["PrivateTask", "Deliverable"]}
    subscriptions = Subscription.all(:conditions => conditions)
    subscriptions.each do |sub|
      puts "Cleaning subscription ##{sub.id}."
      begin
        sub.entity_type = "Task"
        sub.save!
        puts "#{sub.id} updated."
      rescue ActiveRecord::RecordInvalid
        sub.destroy
        puts "#{sub.id} destroyed."
      end
    end
  end

  def self.down
  end
end
