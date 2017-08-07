module Logcraft::Trackable
  extend ActiveSupport::Concern

  included do
    attr_accessor :logcraft_user, :logcraft_source, :logcraft_message,
                  :logcraft_extra_info

    has_many :activities, class_name: 'Logcraft::Activity', as: :trackable
  end

  def create_activity(key, hash = {})
    user       = hash.delete(:user)    || logcraft_user
    source     = hash.delete(:source)  || logcraft_source
    message    = hash.delete(:message) || logcraft_message
    extra_info = hash.present? ? hash : logcraft_extra_info
    activities.create(key: key,
                      user: user,
                      source: source,
                      message: message,
                      extra_info: extra_info)
  end
end
