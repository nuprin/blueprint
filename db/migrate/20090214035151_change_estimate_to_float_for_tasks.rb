class ChangeEstimateToFloatForTasks < ActiveRecord::Migration
  def self.up
    change_column :tasks, :estimate, :decimal, :precision => 5, :scale => 2
  end

  def self.down
    change_column :tasks, :estimate, :tinyint
  end
end
