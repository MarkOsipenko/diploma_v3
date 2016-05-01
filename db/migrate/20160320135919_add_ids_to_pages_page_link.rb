class AddIdsToPagesPageLink < ActiveRecord::Migration
  def change
    add_column :pages_page_links, :page_id, :integer
    add_column :pages_page_links, :page_link_id, :integer
  end
end
