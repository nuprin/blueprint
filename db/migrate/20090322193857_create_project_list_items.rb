class CreateProjectListItems < ActiveRecord::Migration
  def self.up
    create_table :project_list_items do |t|
      t.integer :project_id,  :null => false
      t.integer :category_id, :null => false
      t.integer :position
    end

    Project.update_all "status='active'", "status='Active'"
    
    pc = ProjectCategory.create(:name => "Uncategorized")
    Project.update_all "category_id=#{pc.id}", "category_id IS NULL"

    ProjectCategory.all.each do |pc|
      projects = Project.active.for_category(pc.id)
      projects.sort_by(&:created_at).reverse.each do |p|
        ProjectListItem.create(:project => p, :category => pc)
      end
    end
  end

  def self.down
    drop_table :project_list_items
    category_id = ProjectCategory.find_by_name("Uncategorized")
    Project.update_all "category_id=NULL", "category_id=#{category_id}"
    ProjectCategory.destroy_all "name='Uncategorized'"
  end
end
