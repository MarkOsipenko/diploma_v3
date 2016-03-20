class PageLink < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, uniqueness: { message: "link exist" }, url: true
  # validates :url, format: { with: /\Ahttps:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+\z/ }
  # before_save :enescape_link
  before_create :encoding_link

  def encoding_link
    self.url = URI::unescape(self.url)
  end

  # to Page model
  # def enescape_link
  #   if  self.url != nil
  #     if /^\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === self.url
  #       self.url = "https://#{ detect_domain }#{ self.url }"
  #     elsif /^\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === self.url
  #       self.url = "https:#{ self.url }"
  #     elsif /https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_()-]+$/ === self.url
  #       self.url = self.url
  #     end
  #   end
  # end
  #
  # def detect_domain
  #   Addressable::URI.parse(self.url).host
  # end

  def link_format
    true if /^https:\/\/(ru|en).wikipedia.org\/wiki\/[0-9a-zA-ZА-Яа-я_-]+$/ === self.url
  end
end