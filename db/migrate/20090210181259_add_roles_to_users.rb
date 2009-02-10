class AddRolesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string, :default => ""
    [
      "Brad", "Jennifer", "Kevin", "Josh", "Kristján", "Jimmy", "Ryan"
    ].each do |name|
      u = User.find_by_name(name)
      u.update_attribute(:role, "engineer") if u
    end
    
    ["Susan", "Sarah"].each do |name|
      u = User.find_by_name(name)
      u.update_attribute(:role, "activist") if u
    end
    
    ["Matt", "Joe", "Michel", "Chris"].each do |name|
      u = User.find_by_name(name)
      u.update_attribute(:role, "manager") if u
    end
  end

  def self.down
    remove_column :users, :role
  end
end
