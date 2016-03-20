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
      enescape_link(link['href'])
      # if (link_format(@link_with_domain) == true)
      #   puts @link_with_domain
      #   # self.return_existing_page_link(@link_with_domain)
      #   self.page_links.create(url: @link_with_domain, name: link.text)
      #   self.save
      # end
    end
    # links_in_page
  end

  def enescape_link(link)
    # if /^\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === link
    #   @link_with_domain = "https://#{ detect_domain }#{ link }"
    # elsif /^\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === link
    #   @link_with_domain = "https:#{ self.url }"
    # elsif /https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === link
    #   @link_with_domain = link
    # end
    if /^\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === link
      "https://#{ detect_domain }#{ link }"
    elsif /^\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === link
      "https:#{ link }"
    elsif /https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === link
      link
    end
  end

  def detect_domain
    Addressable::URI.parse(self.url).host
  end

  def link_format(url)
    true if /^https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+$/ === url
  end

end