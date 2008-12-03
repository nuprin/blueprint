class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name, :limit => 50, :null => false
      t.integer :fbuid
    end
  end

  def self.down
    drop_table :users
  end
end
