module Logcraft::Tracker
  extend ActiveSupport::Concern

  included do
    has_many :tracked_activities, class_name: 'Logcraft::Activity', as: :user
  end
end
