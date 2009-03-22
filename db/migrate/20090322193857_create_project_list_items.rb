class CreateProjectListItems < ActiveRecord::Migration
  def self.up
    create_table :project_list_items do |t|
      t.integer :project_id,  :null => false
      t.integer :category_id, :null => false
      t.integer :position,    :null => false
    end
    
    ProjectCategory.all.each do |pc|
      projects = Project.active.for_category(pc.id)
      projects.sort_by(&:created_at).reverse.each do |p|
        ProjectListItem.create(:project => p, :category => pc)
      end
    end
  end

  def self.down
    drop_table :project_list_items
  end
end
