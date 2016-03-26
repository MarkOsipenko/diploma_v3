class PageLink < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, uniqueness: { message: "link exist" }, url: true
  has_many :pages_page_links
  has_many :pages, through: :pages_page_links
  before_create :encoding_link
  # after_create :parse_next_page

  def find_page
    page = Page.find_by_url(self.url)
  end

  def page_custom_create
    u = self.url
    Page.custom_create(u)
  end

  protected

    def encoding_link
      self.url = URI::unescape(self.url)
    end

    # def parse_next_page
    #   id = self.id
    #   PageWorker.perform_async(id)
    # end

end