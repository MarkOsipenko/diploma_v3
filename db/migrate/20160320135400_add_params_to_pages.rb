class AddParamsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :url, :string
    add_column :pages, :body, :text
  end
end
