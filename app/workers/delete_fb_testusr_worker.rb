class DeleteFbTestusrWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(uid)
    Koala::Facebook::TestUsers.new(
      app_id: Settings.Facebook_app_id,
      secret: Settings.Facebook_secret).delete(uid)
  end
end