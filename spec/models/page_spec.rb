require 'rails_helper'

RSpec.describe Page, type: :model do
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
    it { expect(page.enescape_link("//en.wikipedia.org/wiki/Hello")).to eq("https://en.wikipedia.org/wiki/Hello") }
    it { expect(page.enescape_link("/wiki/Hello")).to eq("https://en.wikipedia.org/wiki/Hello") }
    it { expect(page.enescape_link("")).to eq(nil) }

    it { expect(page.enescape_link("https://ru.wikipedia.org/wiki/Анализ")).to eq("https://ru.wikipedia.org/wiki/Анализ") }
    it { expect(page.enescape_link("//ru.wikipedia.org/wiki/Анализ")).to eq("https://ru.wikipedia.org/wiki/Анализ") }
    # вернет en.wikipedia потому что сморит на page
    it { expect(page.enescape_link("/wiki/Анализ")).to eq("https://en.wikipedia.org/wiki/Анализ") }
    it { expect(page.enescape_link("")).to eq(nil) }

  end
end
