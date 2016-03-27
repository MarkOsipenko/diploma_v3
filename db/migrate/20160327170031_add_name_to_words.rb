class AddNameToWords < ActiveRecord::Migration
  def change
    add_column :words, :name, :string
  end
end
