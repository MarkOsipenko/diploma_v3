require 'rails_helper'

RSpec.describe Category, type: :model do
  before { allow_any_instance_of(Page).to receive(:find_links).and_return(["link1"]) }
  
  context "check empty name" do
    let(:empty_cat) { Category.create!(name: "") }
    it { expect{ empty_cat }.to raise_error(ActiveRecord::RecordInvalid) }
  end

  context "check right name and uniqueness category" do
    let!(:cat) { Category.create!(name: "Woodstock") }
    let(:cat_dup) { Category.create!(name: "Woodstock") }
    it { expect(cat.name).to eq("Woodstock") }
    it { expect{ cat_dup }.to raise_error(ActiveRecord::RecordInvalid) }
  end

  context "check accessory page to category" do
    let!(:page) { Page.custom_create("https://en.wikipedia.org/wiki/Curacha") }
    it { expect(page.categories.count).to eq(4) }
  end

end
