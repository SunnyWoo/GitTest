module Deeplink
  extend ActiveSupport::Concern

  included do
    helper_method :deeplink
  end

  def deeplink(link)
    "#{Settings.deeplink_protocol}://#{link}"
  end
end