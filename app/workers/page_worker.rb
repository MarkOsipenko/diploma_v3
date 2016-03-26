class HardWorker
  include Sidekiq::Worker

  def perform(url)
    PageLink.find_by_url(url).page_custom_create
  end

end