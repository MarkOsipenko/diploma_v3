class AddIndexToPageLinks < ActiveRecord::Migration
  def change
    add_column :page_links, :url, :string
    add_index :page_links, :url
    add_column :page_links, :name, :string
    add_index :page_links, :name
  end
end
