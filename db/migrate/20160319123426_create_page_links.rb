class CreatePageLinks < ActiveRecord::Migration
  def change
    create_table :page_links do |t|

      t.timestamps null: false
    end
  end
end
