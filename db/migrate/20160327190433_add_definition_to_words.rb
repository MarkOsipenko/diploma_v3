class AddDefinitionToWords < ActiveRecord::Migration
  def change
    add_column :words, :definition, :string
    add_index :words, :definition
  end
end
