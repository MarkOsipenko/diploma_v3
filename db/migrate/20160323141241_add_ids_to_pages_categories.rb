class AddIdsToPagesCategories < ActiveRecord::Migration
  def change
    add_column :pages_categories, :page_id, :integer
    add_column :pages_categories, :category_id, :integer
  end
end
