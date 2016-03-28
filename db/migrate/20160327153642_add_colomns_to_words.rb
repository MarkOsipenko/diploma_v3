class AddColomnsToWords < ActiveRecord::Migration
  def change
    add_column :words, :page_id, :integer
    add_column :words, :content, :text
  end
end
