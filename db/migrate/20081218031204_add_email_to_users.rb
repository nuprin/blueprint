class AddEmailToUsers < ActiveRecord::Migration
  CAUSES_EMAILS = {
    "Brad"     => 'brad@causes.com',
    "Chase"    => 'chase@causes.com',
    "Chris"    => 'chris@causes.com',
    "Jennifer" => 'jen@causes.com',
    "Jimmy"    => 'jkit@causes.com',
    "Joe"      => 'joe@causes.com',
    "Kevin"    => 'kball@causes.com',
    "Kristján" => 'kristjan@causes.com',
    "Matt"     => 'matt@causes.com',
    "Sarah"    => 'sarah@causes.com',
    "Susan"    => 'susan@causes.com',
  }

  def self.up
    add_column :users, :email, :string, :default => nil
    User.find(:all).each do |user|
      user.email = CAUSES_EMAILS[user.name]
      user.save
    end
  end

  def self.down
    remove_column :users, :email
  end
end
