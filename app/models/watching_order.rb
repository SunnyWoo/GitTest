module WatchingOrder
  extend ActiveSupport::Concern

  def watching_required?
    message.present?
  end

  def watch
    update_column(:watching, true)
  end

  def unwatch
    update_column(:watching, false)
  end
end
