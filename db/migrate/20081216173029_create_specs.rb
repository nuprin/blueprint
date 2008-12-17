class CreateSpecs < ActiveRecord::Migration
  def self.up
    create_table :specs do |t|
      t.integer :project_id
      t.text :body, :default => ""

      t.timestamps
    end
    add_index :specs, :project_id
    Project.all.each do |p|
      spec = Spec.create(:project_id => p.id)
      puts "Creating spec for #{p.title}..."
      if !p.description.blank?
        puts "Updating spec for #{p.title}..."
        spec.update_attribute(:body, p.description)
      end
    end
  end

  def self.down
    drop_table :specs
  end
end
