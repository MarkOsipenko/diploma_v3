require "open-uri"
require "nokogiri"

class Page < ActiveRecord::Base
  validates :url, presence: true, uniqueness: { message: "page url exist" }, url: true
  validates :body, presence: true
  has_many :pages_page_links
  has_many :page_links, through: :pages_page_links
  has_many :pages_categories
  has_many :categories, through: :pages_categories
  has_one :word
  after_create :get_page_content
  after_create :detect_category
  after_create :find_word
  after_create :create_translate
  after_create :find_links

  class << self
    def custom_create(u)
      self.create(url: u, body: generate_body(u))
    end

    def generate_body(u)
      url = URI.encode(u)
      page = Nokogiri::HTML(open(url))
      page.css("#mw-content-text").to_s
    end
  end

  def get_page_content
    url = URI.encode(self.url)
    @result_parsing_page ||= Nokogiri::HTML(open(url))
  end

  def detect_category
    page_categories = @result_parsing_page.css(".mw-normal-catlinks ul a")
    page_categories.each do |categ|
      self.categories.create(name: categ.text) unless self.find_or_create_category(categ.text)
    end
  end

  def find_or_create_category(category)
    categ = Category.where(name: category).first
    self.pages_categories.find_or_create_by(category: categ) unless categ == nil
  end

  def find_links
    links_in_page = @result_parsing_page.css("a")
    links_in_page.each do |link|
      full_link = self.enescape_link(link['href'])
      create_page_link_in_page(full_link, link.text) if check_link_format(full_link)
    end
  end

  def find_word
    content = @result_parsing_page.css("#mw-content-text p").first
    name = @result_parsing_page.css("#firstHeading").text
    content.children.each { |c| c.remove if c.name == 'b' }
    Word.create(definition: name.capitalize, content: content.text, page: self)
  end

  def create_page_link_in_page(full_link, link)
    self.page_links.create(url: full_link, name: link) unless self.find_or_create_page_link(full_link)
  end

  def find_or_create_page_link(link_address)
    page = PageLink.where(url: link_address).first
    self.pages_page_links.find_or_create_by(page_link: page) unless page == nil
  end

  def enescape_link(link)
    if link != nil
      encode_link = URI::unescape(link)
      if /^\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === encode_link
        "https://#{ detect_domain }#{ encode_link }"
      elsif /^\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === encode_link
        "https:#{ encode_link }"
      elsif /https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === encode_link
        encode_link
      end
    end
  end

  def detect_domain
    Addressable::URI.parse(self.url).host
  end

  def check_link_format(url)
    /^https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+$/ === url
  end

  def find_translate
    if detect_domain == "en.wikipedia.org"
      @translate = @result_parsing_page.css("div#p-lang li.interwiki-ru a")
    elsif detect_domain == "ru.wikipedia.org"
      @translate = @result_parsing_page.css("div#p-lang li.interwiki-en a")
    elsif
      @translate = nil
    end
  end

  def create_translate
    find_translate
    if @translate.first != nil
      translate_link = enescape_link(@translate.first['href'])
      if check_link_format(translate_link)
        transl = PageLink.create(url: translate_link, name: @translate.first['title'])
        self.translate = transl.id
      end
    end
  end
end
