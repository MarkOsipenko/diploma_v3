require "open-uri"
require "nokogiri"

class Page < ActiveRecord::Base
  validates :url, presence: true, uniqueness: { message: "page url exist" }, url: true
  validates :body, presence: true
  has_many :pages_page_links
  has_many :page_links, through: :pages_page_links
  has_many :pages_categories
  has_many :categories, through: :pages_categories
  after_create :get_page_content
  after_create :detect_category
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
    category = Category.where(name: category).first
    self.pages_categories.find_or_create_by(category: category) unless category == nil
  end

  def find_links
    links_in_page = @result_parsing_page.css("a")
    links_in_page.each do |link|
      full_link = self.enescape_link(link['href'])
      create_page_link_in_page(full_link, link.text) if check_link_format(full_link)
    end
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
end