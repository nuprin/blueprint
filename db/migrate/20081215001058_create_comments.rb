class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string  :text,      :null => false, :limit => 5000
      t.integer :task_id,   :null => false
      t.integer :author_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
