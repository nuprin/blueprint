class AddDefaultValueToTaskDescriptions < ActiveRecord::Migration
  def self.up
    change_column :tasks, :description, :string, :default => ""
    Task.all.each do |t|
      if t.nil?
        t.update_attribute(:description, "")
      end
    end
  end

  def self.down
    change_column :tasks, :description, :string
  end
end
