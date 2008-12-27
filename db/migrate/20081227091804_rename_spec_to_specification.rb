class RenameSpecToSpecification < ActiveRecord::Migration
  def self.up
    rename_table(:specs, :specifications)
  end

  def self.down
    rename_table(:specifications, :specs)
  end
end
