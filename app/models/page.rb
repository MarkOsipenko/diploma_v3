class Page < ActiveRecord::Base
  validates :url, presence: true, uniqueness: {message: "page url exist"}, url: true, 
  validates :body, presence: true,

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

end
