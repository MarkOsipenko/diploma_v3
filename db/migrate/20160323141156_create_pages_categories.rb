class CreatePagesCategories < ActiveRecord::Migration
  def change
    create_table :pages_categories do |t|

      t.timestamps null: false
    end
  end
end
