class FacebookService
  # 批次更新 網站 work open graph
  def self.update_works_graphs
    include Rails.application.routes.url_helpers

    facebook = Koala::Facebook::OAuth.new(Settings.Facebook_app_id, Settings.Facebook_secret)

    res = facebook.get_app_access_token_info

    if res.present? && res['access_token'].present?
      access_token = res['access_token']
      host = Settings.host

      urls = []
      Work.is_public.find_each do |work|
        I18n.available_locales.each do |local|
          urls << (host + shop_work_path(work.product, work, locale: local))
        end
      end

      batch = []
      urls.each do |url|
        batch << { method: 'POST', body: "id=#{url}&scrape=true" }
      end

      batchs = batch.each_slice(50)

      uri = URI('https://graph.facebook.com/v2.2/')
      batchs.each do |b|
        res = Net::HTTP.post_form(uri, batch: b.to_json, access_token: access_token)
        Rails.logger.info res.body
      end

    end
  end
end
