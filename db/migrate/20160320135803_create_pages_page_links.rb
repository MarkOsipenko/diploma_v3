class CreatePagesPageLinks < ActiveRecord::Migration
  def change
    create_table :pages_page_links do |t|

      t.timestamps null: false
    end
  end
end
