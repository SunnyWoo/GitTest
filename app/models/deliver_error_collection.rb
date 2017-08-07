# == Schema Information
#
# Table name: deliver_error_collections
#
#  id              :integer          not null, primary key
#  order_id        :integer
#  workable_id     :integer
#  workable_type   :string(255)
#  cover_image_url :text
#  print_image_url :text
#  error_messages  :json
#  aasm_state      :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class DeliverErrorCollection < ActiveRecord::Base
  belongs_to :order
  belongs_to :workable, polymorphic: true
  include AASM

  aasm do
    state :pending, initial: true
    state :repairing
    state :completed
    state :failed

    event :repair do
      transitions to: :repairing
    end

    event :finish do
      transitions from: :repairing, to: :completed
    end

    event :failure do
      transitions from: :repairing, to: :failed
    end
  end

  def repair_images_sync
    RepairImagesWorker.perform_async(id)
  end

  def repair_images
    repair!

    # 先用已经获取的image_url尝试修复
    # 如果不成功再call一次api取image_url
    # 如果还是不成功 人工修复吧
    unless upload_images(print_image_url, cover_image_url)
      new_print_image_url, new_cover_image_url = retrieve_image_urls
      unless retry_upload_images(new_print_image_url, new_cover_image_url)
        SlackNotifier.send_msg("抛单修图失败：error_collection: #{id}, order_id: #{order_id}")
        return failure!
      end
    end

    finish!
  end

  def retrieve_image_urls
    response = DeliverOrder::OrderItemService.new(order_item.remote_id).execute

    response['work'].slice('print_image', 'cover_image').values
  end

  def upload_images(print_image_url, cover_image_url)
    workable.remote_print_image_url = print_image_url if workable.print_image.url.blank?
    workable.remote_cover_image_url = cover_image_url if is_archived_work? && workable.cover_image.url.blank?
    workable.save
  end
  alias_method :retry_upload_images, :upload_images

  def order_item
    OrderItem.find_by!(order_id: order_id, itemable_id: workable_id, itemable_type: workable_type)
  end

  def is_archived_work?
    workable.class.name == 'ArchivedWork'
  end
end
