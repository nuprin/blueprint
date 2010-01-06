class CreateIncidents < ActiveRecord::Migration
  def self.up
    create_table :incidents do |t|
      t.string :title
      t.text :description
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end

  def self.down
    drop_table :incidents
  end
end
