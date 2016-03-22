require 'rails_helper'

RSpec.describe Page, type: :model do
  before { allow_any_instance_of(Page).to receive(:find_links).and_return(["link1"]) }
  let!(:page) { create :page }

  context "validates" do
    it { expect(page).not_to be_invalid }
  end

  context "custom_create method" do
    let!(:page) { Page.custom_create("https://ru.wikipedia.org/wiki/Синтаксический_анализ") }
    it { expect(page.url).to eq("https://ru.wikipedia.org/wiki/Синтаксический_анализ") }
  end

  context "enescape_link method" do
    it { expect(page.enescape_link("https://en.wikipedia.org/wiki/Hello")).to eq("https://en.wikipedia.org/wiki/Hello") }
    it { expect(page.enescape_link("//en.wikipedia.org/wiki/Hello")).to       eq("https://en.wikipedia.org/wiki/Hello") }
    it { expect(page.enescape_link("/wiki/Hello")).to                         eq("https://en.wikipedia.org/wiki/Hello") }
    it { expect(page.enescape_link("https://ru.wikipedia.org/wiki/Анализ")).to eq("https://ru.wikipedia.org/wiki/Анализ") }
    it { expect(page.enescape_link("//ru.wikipedia.org/wiki/Анализ")).to       eq("https://ru.wikipedia.org/wiki/Анализ") }
    it { expect(page.enescape_link("/wiki/Анализ")).to                         eq("https://en.wikipedia.org/wiki/Анализ") }
    it { expect(page.enescape_link("//ru.wikipedia.org/wiki/%D0%90%D0%BD%D0%B0%D0%BB%D0%B8%D0%B7")).to eq("https://ru.wikipedia.org/wiki/Анализ") }
    it { expect(page.enescape_link("")).to eq(nil) }
  end

  context "find_links method" do
    let(:page_with_link) { Page.custom_create("https://ru.wikipedia.org/wiki/Лондонская_национальная_галерея") }
    before { allow_any_instance_of(Page).to receive(:find_links).and_call_original }
    it { expect(page_with_link.page_links.count).to eq(138) }
  end

  context "return_existing_page_link method" do
    let!(:page_link) { PageLink.create(url: "https://en.wikipedia.org/wiki/Salutation", name: "Salutation") }
    let(:custom_page) { Page.custom_create("https://en.wikipedia.org/wiki/Hello") }
    before { allow_any_instance_of(Page).to receive(:find_links).and_call_original }
    it { expect(custom_page.page_links.where(url: "https://en.wikipedia.org/wiki/Salutation").exists?).to be(true) }
    it { expect(PageLink.where(url: "https://en.wikipedia.org/wiki/Salutation").count).to eq(1) }
  end

end