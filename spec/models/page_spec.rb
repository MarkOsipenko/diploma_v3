require 'rails_helper'

RSpec.describe Page, type: :model do
  before { allow_any_instance_of(Page).to receive(:find_links).and_return((["arr"])) }
  let(:page) { create :page }

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
    before { allow_any_instance_of(Page).to receive(:find_links).and_call_original }
    let(:page_with_link) { Page.custom_create("https://ru.wikipedia.org/wiki/Лондонская_национальная_галерея") }
    it { expect(page_with_link.page_links.count).to eq(138) }
  end

  context "return_existing_page_link method" do
    before { allow_any_instance_of(Page).to receive(:find_links).and_call_original }
    let!(:page_link) { PageLink.create(url: "https://en.wikipedia.org/wiki/Salutation", name: "Salutation") }
    let(:custom_page) { Page.custom_create("https://en.wikipedia.org/wiki/Hello") }
    it { expect(custom_page.page_links.where(url: "https://en.wikipedia.org/wiki/Salutation").exists?).to be(true) }
    it { expect(PageLink.where(url: "https://en.wikipedia.org/wiki/Salutation").count).to eq(1) }
  end

  context "detect_domain method" do
    let(:rus_page) { Page.custom_create("https://ru.wikipedia.org/wiki/Лондон") }
    it { expect(rus_page.find_links).to eq(["arr"])  }
    it { expect(page.detect_domain).to eq("en.wikipedia.org") }
    it { expect(rus_page.detect_domain).to eq("ru.wikipedia.org") }
  end

  context "detect_category method" do
    let(:detect_category_method) { Page.custom_create("https://en.wikipedia.org/wiki/Hello") }
    let!(:detect_category1_method) { Page.custom_create("https://ru.wikipedia.org/wiki/Москва") }
    it { expect(detect_category_method.categories.count).to eq(2) }

    it { expect(detect_category1_method.categories.count).to eq(17) }
    it { expect(Category.where(name: "Золотое кольцо России").exists?).to be(true) }

    context "return_existing_category method" do
      let!(:exist_categ) { Category.create(name: "Метательное оружие") }
      let(:page) { Page.custom_create("https://ru.wikipedia.org/wiki/Лук_(оружие)") }
      it { expect( Category.where(name: "Метательное оружие").exists?).to be(true) }
      it { expect( page.categories.where(name: "Метательное оружие").exists?).to be(true) }
      it { expect( Category.where(name: "Метательное оружие").count).to eq(1) }
    end

    context "return_existing_category if category existed" do
      let!(:page_cat) { Page.custom_create("https://ru.wikipedia.org/wiki/Мейн-кун") }
      let!(:page_cat2) { Page.custom_create("https://ru.wikipedia.org/wiki/Персидская_кошка") }
      it { expect(Category.where(name: "Породы кошек").count).to eq(1) }
      it { expect(Category.find_by_name("Породы кошек").pages).to include(Page.find_by_url("https://ru.wikipedia.org/wiki/Мейн-кун")) }
      it { expect(Category.find_by_name("Породы кошек").pages).to include(Page.find_by_url("https://ru.wikipedia.org/wiki/Персидская_кошка")) }
    end

    context "check definition" do
      let!(:page1) { Page.custom_create("https://ru.wikipedia.org/wiki/Мумий_Тролль") }
      it { expect(page1.word.definition).to eq("Мумий Тролль") }
    end

    context "check find_translate method" do
      let!(:page_without_translate) { Page.custom_create("https://en.wikipedia.org/wiki/Districts_of_Bangladesh") }
      let!(:page_with_en) { Page.custom_create("https://ru.wikipedia.org/wiki/Бенгальский_язык") }
      let!(:page_with_ru) { Page.custom_create("https://en.wikipedia.org/wiki/Bengali_language") }
      let!(:page1_with_en) { Page.custom_create("https://ru.wikipedia.org/wiki/Андаманские_и_Никобарские_острова") }
      let!(:page1_with_ru) { Page.custom_create("https://en.wikipedia.org/wiki/Andaman_Islands") }
      before { page_without_translate.create_translate }
      it { expect(page_without_translate.translate).to eq(nil) }

      context "check link in one page" do
        before do
          page_with_en.create_translate
          page_with_ru.create_translate
        end

        it { expect(page_with_en.translate).to eq(page_with_ru) }
        it { expect(page_with_ru.translate).to eq(page_with_en) }
      end

    end
  end
end