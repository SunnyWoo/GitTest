class GetuiService
  def initialize(args = {})
    @pusher = IGeTui.pusher(Settings.getui.app_id,
                            Settings.getui.app_key,
                            Settings.getui.master_secret)
  end
end
