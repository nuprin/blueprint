class CreateProjectCategories < ActiveRecord::Migration
  def self.up
    create_table :project_categories do |t|
      t.string :name
    end
    [
      "Business Development",
      "Engineering",
      "Activist",
      "Product"
    ].each do |name|
      ProjectCategory.create(:name => name)
    end
  end

  def self.down
    drop_table :project_categories
  end
end
