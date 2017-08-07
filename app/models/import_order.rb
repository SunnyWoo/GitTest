# == Schema Information
#
# Table name: import_orders
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  aasm_state :string(255)
#  failed     :json
#  created_at :datetime
#  updated_at :datetime
#

class ImportOrder < ActiveRecord::Base
  include AASM
  has_many :succeeds, class_name: 'ImportOrderSucceed'

  mount_uploader :file, CsvUploader
  serialize :failed, Failed::ArraySerializer
  after_commit :import_sync, on: :create
  validates :file, presence: true

  aasm do
    state :pending, initial: true
    state :importing
    state :finished

    event :import do
      transitions to: :importing
    end

    event :finish do
      transitions from: :importing, to: :finished
    end
  end

  def generate_orders
    generate(&:generate_orders_by_file)
  end

  def failed_retry
    generate(&:generate_order_by_failed)
  end

  def generate
    import!
    import = Guanyi::ImportOrder.new(self)
    yield import
    self.failed = import.failed
    save!
    finish!
  end

  def failed_retry_sync
    ImportOrdersWorker.generate_orders_by_failed(id)
  end

  def import_sync
    ImportOrdersWorker.generate_orders_by_file(id)
  end
end
