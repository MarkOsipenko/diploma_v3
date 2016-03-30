require 'rails_helper'

RSpec.describe "Page", type: :feature do
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

end