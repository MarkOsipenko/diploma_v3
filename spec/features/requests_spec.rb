require 'rails_helper'

RSpec.describe "Page", type: :feature do
  before { allow_any_instance_of(Page).to receive(:find_links).and_return(["arr"]) }
  let!(:custom_page) { Page.custom_create("https://ru.wikipedia.org/wiki/Гринвичский_парк") }

  subject { page }

  context "visit single page" do
    before { visit page_path(custom_page) }
    it { is_expected.to have_content("Гринвичский парк") }
  end

  context "visit pages_page_links" do
    before { visit page_links_path }
    it { is_expected.to have_content(PageLink.count) }
  end

  context "visit categories_path" do
    before { visit categories_path }
    it { is_expected.to have_link("Гринвич") }
    it { is_expected.to have_link("Парки Лондона") }
    it { is_expected.to have_link("Сооружения летних Олимпийских игр 2012 года") }

    context "visit one category" do
      let(:cat) { Category.first }
      before { visit category_path(cat) }

      it { is_expected.to have_link("Гринвичский парк") }
    end
  end
end