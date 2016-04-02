
class HardWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'critical'

  def perform(id)
    PageLink.find(id).page_custom_create
  end
end