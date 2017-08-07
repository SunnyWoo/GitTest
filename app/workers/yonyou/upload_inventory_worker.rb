class Yonyou::UploadInventoryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :yonyou
  sidekiq_options retry: false

  def perform(sync_body)
    inventory = Yonyou::Inventory.new
    response = inventory.add(sync_body)
    sleep 4
    inventory.request.get(response.url)
  rescue => e
    SlackNotifier.send_msg("同步存货档案到用友失败: 存货编码-#{sync_body['inventory']['code']}")
    fail YonyouError, e.to_s
  end
end
