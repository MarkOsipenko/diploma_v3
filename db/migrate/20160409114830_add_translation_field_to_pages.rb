class AddTranslationFieldToPages < ActiveRecord::Migration
  def change
    add_column :pages, :translation, :string
  end
end
