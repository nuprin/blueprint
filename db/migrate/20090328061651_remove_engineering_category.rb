class RemoveEngineeringCategory < ActiveRecord::Migration
  def self.up
    engineering = ProjectCategory.find_by_name("Engineering")
    product = ProjectCategory.find_by_name("Product")
    if engineering && product
      engineering.projects.each do |p|
        p.category_id = product.id
        p.save!
      end
      product.update_attribute(:name, "Product & Engineering")
      engineering.destroy
    end
  end

  def self.down
    ProjectCategory.create!(:name => "Engineering")
  end
end
