require "open-uri"
require "nokogiri"

class Page < ActiveRecord::Base
  validates :url, presence: true, uniqueness: { message: "page url exist" }, url: true
  validates :body, presence: true
  has_many :pages_page_links
  has_many :page_links, through: :pages_page_links
  after_create :get_page_content
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

  def find_links
    links_in_page = @result_parsing_page.css("a")
    links_in_page.each do |link|
      full_link = enescape_link(link['href'])
      if (link_format(full_link) == true)
        self.return_existing_page_link(full_link)
        self.page_links.create(url: full_link, name: link.text)
        self.save
      end
    end
    # links_in_page
  end

  def return_existing_page_link(link_address)
    if check_link_exist(link_address)
      self.pages_page_links.create(page_link: PageLink.find_by_url(link_address))
      self.save
    end
  end

  def check_link_exist(link_address)
    true if PageLink.where(url: link_address).exists? && !self.page_links.where(url: link_address).exists?
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

  def link_format(url)
    true if /^https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+$/ === url
  end

end

