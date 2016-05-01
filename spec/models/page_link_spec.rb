require 'rails_helper'

RSpec.describe PageLink, type: :model do
  let!(:current_link) { create :page_link }
  let(:double_current_link) { create :page_link }
  let(:bad_link) { PageLink.create!(url: "1@gmail.com", name: "ruby") }
  let!(:external_link) { PageLink.create!(url: "http://guides.rubyonrails.org/active_record_validations.html", name: "ruby") }
  let!(:rus_link) { PageLink.create!(url: "https://ru.wikipedia.org/wiki/Анализ", name: "Анализ") }
  let!(:rus_link_encode) { PageLink.create!(url: "https://ru.wikipedia.org/wiki/%D0%A1%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%B8%D0%B9_%D0%B0%D0%BD%D0%B0%D0%BB%D0%B8%D0%B7", name: "Анализ") }
  let!(:rus_link1_encode) { PageLink.create!(url: "https://ru.wikipedia.org/wiki/%D0%9A%D0%B2%D0%B8%D0%BD%D1%82_%D0%A1%D0%B5%D1%80%D0%B2%D0%B8%D0%BB%D0%B8%D0%B9_%D0%A6%D0%B5%D0%BF%D0%B8%D0%BE%D0%BD_(%D0%BF%D1%80%D0%BE%D0%BA%D0%BE%D0%BD%D1%81%D1%83%D0%BB_90_%D0%B3%D0%BE%D0%B4%D0%B0_%D0%B4%D0%BE_%D0%BD._%D1%8D.)", name: "Анализ") }

  context "validates" do
    it { expect(current_link.name).to eq("Hello")}
    it { expect{ double_current_link }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Url link exist") }
    it { expect(external_link).not_to be_invalid }
    it { expect{ bad_link }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Url is not a valid URL") }
    it { expect(rus_link).to be_valid }
    it { expect(rus_link_encode).to be_valid }
    it { expect(rus_link_encode.url).to eq("https://ru.wikipedia.org/wiki/Синтаксический_анализ") }
    it { expect(rus_link1_encode).to be_valid }
  end

  context "find_page method" do
    before { allow_any_instance_of(Page).to receive(:find_links) }
    let!(:page) { Page.custom_create("https://ru.wikipedia.org/wiki/Тридцать_дней") }
    let!(:page_link) { PageLink.create!(url: "https://ru.wikipedia.org/wiki/Тридцать_дней", name: "Тридцать дней") }

    it { expect(page_link.find_page).to eq(page) }

  end

end