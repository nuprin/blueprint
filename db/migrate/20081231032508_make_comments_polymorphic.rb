class MakeCommentsPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :comments, :task_id, :commentable_id
    add_column :comments, :commentable_type, :string, :null => false,
      :default => "Task"
  end

  def self.down
    rename_column :comments, :commentable_id, :task_id
    remove_column :comments, :commentable_type
  end
end
