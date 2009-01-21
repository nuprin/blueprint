class AddGenderToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gender, :string, :length => 1, :default => "M" # Sigh.
    
    ladies = ["Jennifer", "Sarah", "Susan"]
    User.all(:conditions => {:name => ladies}).each do |u|
      u.update_attribute(:gender, "F")
    end
  end

  def self.down
    remove_column :users, :gender
  end
end
