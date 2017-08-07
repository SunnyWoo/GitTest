module ActsAsIsEnabled
  extend ActiveSupport::Concern

  included do
    scope :enabled, -> { where(is_enabled: true) }
    scope :disabled, -> { where(is_enabled: false) }
  end

  def enable
    update_attributes is_enabled: true
  end

  def disable
    update_attributes is_enabled: false
  end
end
