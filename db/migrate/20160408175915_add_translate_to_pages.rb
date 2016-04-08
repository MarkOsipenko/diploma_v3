class AddTranslateToPages < ActiveRecord::Migration
  def change
    add_column :pages, :translate, :integer
  end
end
