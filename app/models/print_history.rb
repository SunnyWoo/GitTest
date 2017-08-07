# == Schema Information
#
# Table name: print_histories
#
#  id            :integer          not null, primary key
#  print_item_id :integer
#  timestamp_no  :integer
#  print_type    :string(255)
#  reason        :string(255)
#  prepare_at    :datetime
#  print_at      :datetime
#  onboard_at    :datetime
#  sublimated_at :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  qualified_at  :datetime
#  shipped_at    :datetime
#

class PrintHistory < ActiveRecord::Base
  include Logcraft::Trackable
  belongs_to :print_item

  validates :print_type, inclusion: %w(print warehouse_retprint factory_retprint
                                       customer_service_retprint upload_fail_reprint)
  validates :reason, presence: true, unless: :first_print?
  REPRINT_TYPE_OPTION = { factory_retprint: '工廠瑕疵重印',
                          warehouse_retprint: '倉儲質檢重印',
                          customer_service_retprint: '客服退貨重印',
                          upload_fail_reprint: '上傳卡單重印' }.freeze

  after_create :reprint_relation

  def reprint_type_text
    REPRINT_TYPE_OPTION[print_type.to_sym]
  end

  def print_type_text
    return '原始訂單' if print_type == 'print'
    reprint_type_text
  end

  def first_print?
    print_type == 'print'
  end

  def create_log
    activities.find_by(key: :create)
  end

  private

  def reprint_relation
    return if print_type == 'print' || print_item.package_id.blank?
    Print::ReprintRelationService.new(print_item.id, print_type).execute
  end
end
