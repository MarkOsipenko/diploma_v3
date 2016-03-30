
class HardWorker
  include Sidekiq::Worker
  def perform(id)
    PageLink.find(id).page_custom_create
  end
end