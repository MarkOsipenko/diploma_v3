class AddNameToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :name, :string
    add_index :categories, :name
  end
end
