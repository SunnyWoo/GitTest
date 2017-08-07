# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  aasm_state            :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  price                 :float
#  currency              :string(255)
#  payment_id            :string(255)
#  order_no              :string(255)
#  work_state            :integer          default(0)
#  refund_id             :string(255)
#  ship_code             :string(255)
#  uuid                  :string(255)
#  coupon_id             :integer
#  payment               :string(255)
#  order_data            :hstore
#  payment_info          :json             default({})
#  approved              :boolean          default(FALSE)
#  invoice_state         :integer          default(0)
#  invoice_info          :json
#  embedded_coupon       :json
#  subtotal              :decimal(8, 2)
#  discount              :decimal(8, 2)
#  shipping_fee          :decimal(8, 2)
#  shipping_receipt      :string(255)
#  application_id        :integer
#  message               :text
#  shipped_at            :datetime
#  viewable              :boolean          default(TRUE)
#  paid_at               :datetime
#  remote_id             :integer
#  delivered_at          :datetime
#  deliver_complete      :boolean          default(FALSE)
#  remote_info           :json
#  approved_at           :datetime
#  merge_target_ids      :integer          default([]), is an Array
#  packaging_state       :integer          default(0)
#  shipping_state        :integer          default(0)
#  shipping_fee_discount :decimal(8, 2)    default(0.0)
#  flags                 :integer
#  watching              :boolean          default(FALSE)
#  invoice_required      :boolean
#  checked_out_at        :datetime
#  lock_version          :integer          default(0), not null
#  enable_schedule       :boolean          default(TRUE)
#  source                :integer          default(0), not null
#  channel               :string(255)
#  order_info            :json
#

class Order < ActiveRecord::Base
  serialize :embedded_coupon, EmbeddedCoupon
  serialize :remote_info, Hashie::Mash.pg_json_serializer
  serialize :order_info, Hashie::Mash.pg_json_serializer
  store_accessor :order_data, :platform, :ip, :user_agent, :invoice_number, :invoice_memo, :locale, :sms_job_id,
                 :taobao_order_id, :invoice_number_created_at, :bdevent_id, :guanyi_purchase_code, :guanyi_trade_code,
                 :sms_pay_notice_job_id, :cancel_order_job_id,
                 :order_locked_fallback_job_id, :order_locked_supply_job_id,
                 :need_mark_merge_target_ids
  attr_accessor :stripe_card_token
  attr_accessor :refund_memo
  attr_accessor :price_without_shipping_fee

  include HasUniqueUUID
  include OptimisticallyLockable
  include Logcraft::Trackable
  include InvoiceService
  include OrderCancelWorker
  include OrderWorker
  include RedisCacheable
  include CombinedShipping
  include WatchingOrder

  has_paper_trail
  PAYMENTS_SUBSTITUTE = %w(redeem).freeze
  PAYMENTS_V2 = %w(paypal cash_on_delivery neweb/atm neweb/mmk neweb/alipay neweb_mpp stripe).freeze
  PAYMENTS_CHINA = %w(pingpp_alipay pingpp_alipay_wap pingpp_wx pingpp_upacp pingpp_bfb
                      pingpp_upacp_wap pingpp_alipay_qr pingpp_alipay_pc_direct camera360
                      pingpp_upacp_pc pingpp_wx_pub_qr nuandao_b2b taobao_b2c tianmao_b2c).freeze
  PAYMENTS = PAYMENTS_SUBSTITUTE + PAYMENTS_V2 + PAYMENTS_CHINA + PAYMENTS_SUBSTITUTE

  DELAY_PAYMENTS = %w(neweb/atm neweb/mmk).freeze
  PRICE_LOCKED_SESSION = 5.minutes.freeze
  DEFAULT_PRICE_TYPE = 'special'.freeze
  ORDER_FLAG_TYPES = %i(internal_transfer external_transfer combined_shipping).freeze

  value :locked
  bitmask :flags, as: ORDER_FLAG_TYPES

  belongs_to :user
  belongs_to :coupon
  belongs_to :application, class_name: 'Doorkeeper::Application', foreign_key: 'application_id'

  has_many :deliver_error_collections
  has_many :order_items, dependent: :destroy
  has_many :print_items, through: :order_items
  has_many :packages, -> { group('packages.id') }, through: :print_items
  has_many :notes, as: :noteable, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :waybill_routes # TODO: remove after migration
  has_many :adjustments, dependent: :destroy
  has_many :order_adjustments, class_name: 'Adjustment', as: :adjustable
  has_many :item_adjustments, through: :order_items, source: :adjustments

  has_one :billing_info, as: :billable, dependent: :destroy
  has_one :shipping_info, as: :billable, dependent: :destroy
  has_one :approved_activity, -> { where(key: 'approved') }, class_name: 'Logcraft::Activity', as: :trackable
  has_one :guanyi_order, class_name: 'ImportOrderSucceed'

  validates_associated :order_items
  validates :remote_id, uniqueness: true, allow_blank: true
  validates :billing_info, :shipping_info, associated_bubbling: true
  validates :currency, presence: true
  validate :validates_should_satisfy_coupon_condition
  validates :payment, inclusion: { in: PAYMENTS }

  after_create :set_order_no, :create_create_activity
  after_create :enqueue_cancel_order, unless: :delay_payment?
  before_save :check_payment

  after_save :increase_coupon_usage_count, :check_coupon, if: :coupon_id_changed?
  before_update :unbind_coupon, if: :coupon_id_changed?
  after_update :create_approved_activity, :enqueue_nuandao_order_shipping
  after_update :create_state_changed_activity, :create_invoice_state_changed_activity, :check_aasm_state
  before_validation :execute_auto_approve, if: :paid?
  after_update :enqueue_imposite_and_upload, :deliver_order_to_remote, if: :become_approved?
  after_update :push_remote_info
  after_commit :payment_remind, on: :create
  after_commit :mark_merge_target_ids, on: :update, if: :can_merge_order?
  before_save :cancel_remote_order_sync, on: :save, if: :need_cancel_sync?

  scope :can_package, -> { where(can_package: true) }
  scope :should_invoices, -> { user_was_paid.where(payment: Order.should_invoice_payments).where('price > 0') }
  scope :payment_by_neweb, lambda {
    where(payment: ['neweb/atm', 'neweb/mmk', 'neweb/alipay', 'neweb_mpp'])
      .where('price > 0')
  }
  scope :user_was_paid, -> { where(aasm_state: %w(paid shipping part_refunded part_refunding)) }
  scope :not_yet_paid, -> { where(aasm_state: %w(pending waiting_for_payment)) }
  scope :on_date, ->(date) { where("DATE(created_at + interval '8 hours') = ?", date) }
  scope :unapproved, -> { where(approved: false) }
  scope :approved, -> { where(approved: true) }
  scope :viewable, -> { where(viewable: true) }
  scope :delivery, -> { where.not(delivered_at: nil) }
  scope :not_delivery, -> { where(delivered_at: nil) }
  scope :with_states, ->(*states) { where(aasm_state: states) }
  scope :watching, -> { where(watching: true) }

  enum work_state: [:ongoing, :working, :finish]
  enum packaging_state: [:package_ongoing, :part_packaged, :all_packaged]
  enum shipping_state: [:shipping_ongoing, :part_shipping, :all_shipping]
  enum invoice_state: [:invoice_not_upload, :invoice_ready_upload, :invoice_uploading,
                       :invoice_upload_error, :invoice_uploaded, :invoice_finish, :invoice_free]
  enum source: { commandp: 0, b2b: 1, shop: 2 }

  delegate :name, :phone, :address, :city, :state, :zip_code, :country,
           :country_code, :shipping_way, :email, to: :billing_info,
                                                 prefix: true, allow_nil: true

  delegate :name, :phone, :address, :city, :state, :zip_code, :country,
           :country_code, :shipping_way, :email, to: :shipping_info,
                                                 prefix: true, allow_nil: true

  delegate :redeem?, :nuandao_b2b?, to: :payment_inquiry
  delegate :guanyi_trade_code, :guanyi_platform_code, to: :guanyi_order, prefix: true, allow_nil: true

  UNRANSACKABLE_ATTRIBUTES = ['updated_at'].freeze

  accepts_nested_attributes_for :shipping_info

  attr_accessor :pricing_identifier

  mount_uploader :shipping_receipt, DefaultWithMetaUploader

  class << self
    def reconciliation
      Order.not_yet_paid.after(5.days.ago.beginning_of_day).find_each do |order|
        if order.payment != 'cash_on_delivery' && order.payment_object.paid?
          order.create_activity(:reconciliation)
          order.pay!
        end
      end
    end

    def build_for_api_pricing!(user, params)
      order_items = Array(params.delete(:order_items))
      fail ApplicationError, 'order_items can\'t be blank' unless order_items.any?
      params[:items] = order_items.map do |order_item|
        case order_item[:type]
        when 'create'
          { product_model_key: order_item[:product_model_key], quantity: order_item[:quantity] }
        when 'shop'
          { work_uuid: order_item[:work_uuid], quantity: order_item[:quantity] }
        end
      end

      order = new.tap { |new_order| new_order.build_tmp_order(params) }

      # 因為 build_tmp_order 沒有驗證 coupon code
      # 但 Coupon 的驗證需要 一個 order 來驗證，所以先建立一個 tmp order 來 valid coupon
      # 再跑一次 build_tmp_order 是為了 帶入 coupon 後，重新 calculate_price
      if params[:coupon].present? && Coupon.find_valid(params[:coupon], user, order)
        params[:coupon_code] = params[:coupon]
        order = new.tap { |new_order| new_order.build_tmp_order(params) }
      end
      order
    end

    def ransackable_attributes(_auth_object = nil)
      (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
    end

    def payments
      %w(paypal cash_on_delivery neweb/atm neweb/mmk neweb/alipay neweb_mpp stripe)
    end

    def should_invoice_payments
      ['cash_on_delivery', 'neweb/atm', 'neweb/mmk', 'neweb/alipay', 'neweb_mpp', 'stripe', 'paypal']
    end

    private

    def recreate_report
      Report.destroy_all
      Order.user_was_paid.each { |o| o.send :export_order_report_to_redis }
      ReportService.execute_all_updates
    end
  end

  include AASM

  aasm do
    state :pending, initial: true
    state :waiting_for_payment
    state :paid
    state :canceled
    state :packaged # TODO: remove
    state :shipping
    state :refunding
    state :refunded
    state :part_refunding
    state :part_refunded

    event :pay do
      transitions from: :pending, to: :paid
      transitions from: :waiting_for_payment, to: :paid
      after do
        ReceiptSender.perform_in(10.minutes, id) unless user == User.find_by(email: 'deliverorder@commandp.com')
        export_order_report_to_redis
        update_invoice_info if is_need_create_invoice?
        enqueue_post_to_mailgun_mailing_list
        execute_auto_approve if can_auto_approve?
        cancel_worker_collect
        self.paid_at = Time.zone.now
        self.need_mark_merge_target_ids = true
        enqueue_calculate_bought_count_for_product_template
        enqueue_calculate_bought_count_for_standardized_work
        enqueue_send_payment_notification_from_shop if shop?
        save!
      end
    end

    event :prepare_payment do
      transitions from: :pending, to: :waiting_for_payment
      after do
        ReceiptWithStatusSender.perform_in(30.seconds, id)
        sms_worker_collect
        enqueue_send_payment_notification_from_shop if shop?
      end
    end

    event :cancel do
      transitions from: [:pending, :waiting_for_payment], to: :canceled
      after do
        export_order_report_to_redis
        cancel_worker_collect
      end
    end

    # TODO: remove
    event :packaging do
      transitions from: :paid, to: :packaged, guard: false
    end

    event :ship do
      transitions from: :paid, to: :shipping
      after do
        invoice_ready_upload! if invoice_not_upload?
        update! work_state: :finish, shipped_at: Time.zone.now, shipping_state: :all_shipping
        create_activity(:shipped, shipping_way: shipping_info_shipping_way, ship_code: ship_code)
        delete_merge_target_ids if merge_target_ids.present?
      end
    end

    # 目前只有pingpp的退款会有 begin_part_refund  begin_refund
    event :begin_part_refund do
      transitions from: [:paid, :part_refunded, :shipping, :part_refunding], to: :part_refunding
    end

    event :begin_refund do
      transitions from: [:paid, :part_refunded, :shipping, :part_refunding], to: :refunding
    end

    event :refund do
      transitions from: [:paid, :part_refunded, :shipping, :packaged, :refunding, :part_refunding], to: :refunded
      after do
        update_invoice_info if is_need_create_invoice?
      end
    end

    event :part_refund do
      transitions from: [:paid, :part_refunded, :shipping, :packaged, :part_refunding, :refunding], to: :part_refunded
      after do
        update_invoice_info if is_need_create_invoice?
      end
    end
  end

  def temp_item_adjustments_by_promotion
    adjustments.select{ |adj| adj.adjustable_type == 'OrderItem' && adj.source_type =~ /^Promotion/ }
  end

  def approve!
    self.class.with_optimistic_locking do
      return true if approved?
      attrs = { approved: true, approved_at: Time.zone.now }
      attrs[:flags] = flags << :external_transfer if external_production?
      attrs[:watching] = true if watching_required?
      update!(attrs)
      order_items.each(&:clone_to_print_items)
    end
  end

  def user_was_paid?
    aasm_state.in? %w(paid shipping part_refunded part_refunding)
  end

  def all_print_image_exist?
    order_items.all?(&:print_image_exist?)
  end

  def build_order(order_content, options = {})
    builder = Pricing::OrderBuilder.new(self, order_content, options)
    builder.perform!
  end

  #
  # 建立 tmp Order for shipping cart
  # @params['items'] Array ['work_id': 123, 'quantity': 1]
  # @params['currency'] String
  # @params['coupon_code'] String
  #
  # @return nil
  # def build_tmp_order(items, currency = 'USD')
  def build_tmp_order(params)
    builder = Pricing::OrderBuilder.new(self, params, temp: true)
    builder.perform!
  end

  def record_order_data(request_params)
    request_params.each do |k, v|
      send("#{k}=", v) if Order.stored_attributes[:order_data].include?(k.to_sym)
    end
  end

  def coupon=(coupon)
    super
    self.embedded_coupon = coupon.try(:embedded)
  end

  concerning :Price do
    def price_calculator(currency = nil)
      @price_calculator = Pricing::OrderPriceCalculator.new(self, currency)
    end

    def order_items_total(currency = self.currency)
      order_items.to_a.sum(&:subtotal).fetch(currency)
    end

    def sub_total
      order_items_total
    end

    def price_before_coupon(currency = self.currency)
      order_items_total(currency)
    end

    def shipping_price(currency = self.currency)
      ::Price.new(shipping_fee, self.currency).fetch(currency)
    end

    # No currency need?
    def coupon_price
      (adjustments.select(&:discount?).map(&:value).sum * -1) || discount
    end

    def base_price_type
      embedded_coupon.try(:base_price_type) || DEFAULT_PRICE_TYPE
    end
  end

  def currency_price(currency)
    return price if self.currency == currency
    ::Price.in_currency(price, self.currency, currency)
  end

  def price_after_refund(target_currency = currency)
    if price.nil?
      price_calculator.price_after_refund(target_currency)
    else
      value = (price - price_calculator.refund)
      ::Price.new(value, currency)[target_currency]
    end
  end

  concerning :TWDPrice do
    # 輸入金額轉換成台幣
    # @param tmp_price Integer 欲轉換的金額
    #
    # @return Integer TWD price
    def render_twd(tmp_price)
      ::Price.new(tmp_price, currency).fetch('TWD')
    end

    def render_twd_price
      ::Price.new(price, currency).fetch('TWD')
    end

    def render_twd_price_after_refund
      price_after_refund('TWD')
    end
  end

  def paypal_refund_info
    refund = PaypalService.refund_info(refund_id) if refund_id
    refund if refund && refund.id
  rescue StandardError => e
    Rails.logger.warn "suppressed error: #{e}"
  end

  def paypal_sale_id
    PaypalService.get_sale_id(payment_id) if payment_id
  rescue StandardError => e
    Rails.logger.warn "suppressed error: #{e}"
  end

  def check_pay_zero(payment_id)
    if payment_id == '0' && price.to_i == 0
      pay!
      true
    elsif payment_id == '0' && price.to_i > 0
      errors.add(:base, 'Check pay zero false')
      false
    end
  end

  def payment_object
    Payment.for(self)
  end

  def payment_id
    payment_info['payment_id'] || super
  end

  def payment_id=(value)
    super
    payment_info_will_change!
    payment_info['payment_id'] = value
  end

  def payment=(value)
    super
    payment_info_will_change!
    payment_info['method'] = value
  end

  def payment
    payment_info['method'] || super
  end

  alias_method :payment_method, :payment

  def payment_method=(value)
    self.payment = value
  end

  def send_receipt
    return unless notifiable?
    mailers = %w(receipt download)
    mailers.each do |mailer|
      mail = OrderMailer.send(mailer, user_id, id, locale)
      next unless mail.deliver
      message = Message.create(user: user, mail: mail, order_no: order_no)
      create_activity(:send_receipt, email: mail.to.join(', '),
                                     mailer: mailer,
                                     locale: locale,
                                     message_id: message.id)
    end
  end

  def send_store_receipt
    mail = OrderMailer.send(:store_receipt, user_id, id, locale)
    mail.deliver
    message = Message.create(user: user, mail: mail, order_no: order_no)
    create_activity(:send_store_receipt, email: mail.to.join(', '),
                                         mailer: :store_receipt,
                                         locale: locale,
                                         message_id: message.id)
  end

  def send_payment_remind
    return unless may_pay?
    return unless notifiable?
    mail = OrderMailer.payment_remind(id, locale)
    return unless mail.deliver
    message = Message.create(user: user,
                             title: mail.subject,
                             body: mail.html_part.body.to_s,
                             mail_to: mail.to.join(', '),
                             order_no: order_no)
    create_activity(:send_payment_remind, email: mail.to.join(', '),
                                          locale: locale,
                                          message_id: message.id)
  end

  def send_receipt_with_status
    return unless notifiable?
    mail = OrderMailer.receipt_with_status(user_id, id, locale)
    return unless mail.deliver
    message = Message.create(user: user,
                             title: mail.subject,
                             body: mail.html_part.body.to_s,
                             mail_to: mail.to.join(', '),
                             order_no: order_no)
    create_activity(:send_receipt_with_status,
                    message_id: message.id,
                    email: billing_info.email,
                    locale: locale)
  end

  def send_warning
    mail = OrderMailer.conflict_warning(id, locale)
    return unless mail.deliver
    create_activity(:send_warning, message: I18n.t('email.order.conflict.create_log'))
  end

  def created_source
    if activities.first.try { |activity| activity.source[:os_type] }.nil?
      activities.find_by(key: :create).try { |activity| activity.source[:os_type] }
    else
      activities.first.source[:os_type]
    end
  end

  def can_refund?
    if may_refund?
      if price_after_refund > 0
        true
      elsif price_after_refund < 0
        errors.add(:base, I18n.t('orders.show.h3_refund.error_messages.price_after_refund_less_than_zero'))
        false
      else
        errors.add(:base, I18n.t('orders.show.h3_refund.error_messages.price_after_refund_equals_zero'))
        false
      end
    else
      errors.add(:base, I18n.t('orders.show.h3_refund.error_messages.not_allowed'))
      false
    end
  end

  # TODO: check platform
  #
  # [export_order_report_to_redis description]
  #
  # @return nil
  def export_order_report_to_redis
    return false if order_items.size == 0
    ReportService.request_update(self)
  end

  def receipt_deliverable?
    !(pending? || canceled?)
  end

  def pingpp_alipay_payment?
    payment.in? %w(pingpp_alipay pingpp_alipay_wap pingpp_alipay_qr pingpp_alipay_pc_direct)
  end

  def print_items_count
    order_items.reduce(0) do |count, order_item|
      count + order_item.quantity
    end
  end

  def china_archive_attributes
    {
      order_id: id,
      order_no: order_no,
      payment: payment,
      order_items: need_deliver_order_items.map(&:china_archive_attributes),
      single_item: single_item?
    }
  end

  def single_item?
    order_items.sum(:quantity) == 1
  end

  # TODO: original name: deliver_order_items
  def need_deliver_order_items
    order_items.select(&:need_deliver?)
  end

  def have_deliver_order_items?
    need_deliver_order_items.any?
  end

  def delivered?
    delivered_at.present?
  end

  def deliver_complete!
    update_attribute(:deliver_complete, true)
  end

  def remote_work_state
    remote_info['work_state'] || 'ongoing'
  end

  def remote_aasm_state
    remote_info['aasm_state'] || 'paid'
  end

  def need_cancel_sync?
    delivered? && aasm_state_changed?(to: 'canceled')
  end

  def cancel_remote_order_sync
    unless DeliverOrder::CancelRemoteOrder.new(self).execute
      errors.add(:base, 'cancel sync failed')
      false
    end
  end

  # 抛单条件(同时满足)
  #  1. 审核通过
  #  2. 存在需要抛单的order_item
  #  3. 没有抛单过的订单
  def deliver_order_to_remote
    if approved? && have_deliver_order_items? && !delivered?
      DeliverOrderWorker.perform_async(id)
    end
  end

  def ship_strategy
    order_items_all_shipping? ? ship! : part_ship!
  end

  def package_strategy
    order_items_all_onboard? ? all_package! : part_package!
  end

  def can_be_packaged_all?
    print_items.present? && print_items.pluck(:aasm_state).all? { |state| %w(received qualified).include?(state) }
  end

  def update_remote_info(remote_info)
    remote_info[:order_items].each do |item|
      order_item = order_items.find_by_id(item[:id])
      next if order_item.blank?
      order_item.update_column(:remote_info, aasm_state: item[:aasm_state])
    end
    update_column(:remote_info, remote_info[:order])
  end

  def push_remote_info
    PushRemoteInfoWorker.perform_in(1.minute, id) if remote_id.present?
  end

  def notifiable?
    !nuandao_b2b?
  end

  def check_pricing_identifier!(value)
    fail OrderPriceExpirationError if Api::V3::OrderDecorator.new(self).pricing_identifier != value
    true
  end

  def locked?
    persisted? ? locked.to_b : false
  end

  def locked!
    return unless persisted?
    self.locked = true
    locked.expire(PRICE_LOCKED_SESSION)
    true
  end

  def unlocked!
    self.locked = false if persisted?
  end

  def remove_coupon
    return unless coupon.present?
    return unless pending?
    create_activity(:remove_coupon, coupon_id: coupon_id)
    update(coupon: nil)
    calculate_price!
  end

  # Caused by coupon expired
  def adjustments_coupon_revert!
    transaction do
      adjustments.discount.where(source: coupon).find_each(&:revert!)
      remove_coupon
    end
  end

  def calculate_price!
    ans = calculate_price
    save! && ans
  end

  def weight
    order_items.map(&:weight).sum
  end

  def bulding_shipping_and_billing_info(shipping_attrs, billing_attrs)
    build_shipping_info(BillingProfile.normalize_address_params(shipping_attrs))
    build_billing_info(BillingProfile.normalize_address_params(billing_attrs))
  end

  # Was not used yet
  def apply_with_available_promotion
    return unless pending? && !locked?

    avilable_order_level_promotions.each do |promotion|
      promotion.build_apply_adjustment self
    end
  end

  def apply_with_avaliable_shipping_fee_promotion
    return unless pending? && !locked?

    exists = order_adjustments.select(&:for_shipping_fee?).reject do |adj|
      if adj.persisted? && !adj.source.applicable?(self) && !adj.reverted?
        order_adjustments.delete(adj)
        adj.destroy
        true
      else
        false
      end
    end

    return if exists.any?

    if promotion = available_shipping_fee_promotions.first
      promotion.build_apply_adjustment self
    end
  end

  def adjustable_name
    self.class.name
  end

  # 外部拋單 (灣得)
  def external_production?
    order_items.any?(&:external_production?)
  end

  def to_serial_units
    order_items.map do |item|
      item.quantity.times.to_a.map { |n| Pricing::SerialUnit.new(item, n.succ) }
    end.flatten
  end

  def pricing=(result)
    self.subtotal = result.subtotal
    self.discount = result.discount
    self.shipping_fee = result.shipping
    self.shipping_fee_discount = result.shipping_fee_discount
    self.price_without_shipping_fee = result.price_without_shipping_fee
    self.price = result.price
  end

  def disable_schedule
    transaction do
      update_column(:enable_schedule, false)
      print_items.each(&:disable_schedule)
    end
  end

  def calculate_bought_count_for_product_template
    items = order_items.joins("
              left join archived_works ON order_items.itemable_type = 'ArchivedWork' AND order_items.itemable_id = archived_works.id
              left join works ON order_items.itemable_type = 'Work' AND order_items.itemable_id = works.id
            ").where('archived_works.product_template_id IS NOT NULL OR works.product_template_id IS NOT NULL')

    return if items.empty?

    items.each do |item|
      product_template = item.itemable.product_template
      product_template.with_lock do
        product_template.update bought_count: (product_template.bought_count + item.quantity)
      end
    end
  end

  def calculate_bought_count_for_standardized_work
    items = order_items.where(itemable_type: 'ArchivedStandardizedWork')

    return if items.empty?

    items.each do |item|
      standardized_work = item.itemable.original_work
      next if standardized_work.nil?
      standardized_work.with_lock do
        standardized_work.update bought_count: (standardized_work.bought_count + item.quantity)
      end
    end
  end

  def shop_name
    return unless shop?
    Store.find(channel).name
  end

  private

  def payment_inquiry
    payment.to_s.inquiry
  end

  def part_ship!
    update! shipping_state: :part_shipping
    create_activity(:part_shipped)
  end

  def part_package!
    update! packaging_state: :part_packaged
    create_activity(:part_packaged)
  end

  def all_package!
    update! packaging_state: :all_packaged
    create_activity(:all_packaged)
  end

  def order_items_all_shipping?
    aasm_state = order_items.pluck(:aasm_state)
    aasm_state.all? { |state| state == 'shipping' }
  end

  def order_items_all_onboard?
    aasm_state = order_items.pluck(:aasm_state)
    aasm_state.all? { |state| %w(onboard shipping).include?(state) }
  end

  def set_order_no
    OrderNoService.new(self).assign_order_no
  end

  def check_and_assign_coupon(coupon_code)
    coupon = Coupon.find_coupon(coupon_code)
    if coupon.present? && coupon.can_use?(user, self)
      self.coupon = coupon
    else
      errors.add(:base, "Can't find a valid coupon with code #{coupon_code}")
    end
  end

  def assign_billing_info(billing_info)
    build_billing_info(billing_info)
  end

  def calculate_price(_custom_currency = currency)
    self.pricing = price_calculator.process!
  end

  def check_payment
    case payment
    when 'cash_on_delivery'
      shipping_info.shipping_way = 'cash_on_delivery'
    when 'nuandao_b2b'
      self.source = 'b2b'
      self.channel = 'nuandao'
    end
  end

  def create_approved_activity
    create_activity(:approved, print_items_expected_count: print_items_count,
                               print_items_actual_count:   print_items.count,
                               print_order_items_ids:      print_items.map(&:order_item_id).uniq,
                               order_items_ids:            order_items.map(&:id)
                   ) if approved_changed? && approved?
  end

  def create_state_changed_activity
    create_activity(:state_changed, state_change: aasm_state_change) if aasm_state_changed? && !aasm_state_was.nil?
  end

  def create_invoice_state_changed_activity
    return unless invoice_state_changed?
    create_activity(:update_invoice,
                    invoice_state_change: invoice_state_change,
                    invoice_number: invoice_number,
                    invoice_memo: invoice_memo,
                    source: { channel: 'invoice' })
  end

  def check_aasm_state
    export_order_report_to_redis if aasm_state_changed?
  end

  def create_create_activity
    create_activity(:create)
  end

  ransacker :platform do |parent|
    Arel::Nodes::InfixOperation.new('->', parent.table[:order_data], 'platform')
  end

  ransacker :remote_no do |parent|
    Arel.sql "(#{parent.table.name}.remote_info->>'order_no')"
  end

  def validates_should_satisfy_coupon_condition
    return unless embedded_coupon

    return if embedded_coupon.pass_condition?(price_calculator, currency)
    errors.add(:coupon, :coupon_condition_is_not_satisfied)
  end

  def increase_coupon_usage_count
    return if payment == 'redeem' && aasm_state == 'pending'
    return unless coupon
    coupon.increment!(:usage_count)
    coupon.parent.increment!(:usage_count) if coupon.parent.present?
  end

  def check_coupon
    # https://app.asana.com/0/9672537926113/41375247378926
    return unless coupon.present? && coupon.code == 'MUGSH0000'
    notes.create(message: '中國工廠測試生產用，請直接審核，工廠無需製作')
  end

  # when chagne coupon, should release before coupon
  # https://app.asana.com/0/9672537926113/105169920950175
  def unbind_coupon
    if coupon_id_was.present?
      coupon_was = Coupon.find(coupon_id_was)
      coupon_was.decrement!(:usage_count)
      adjustments.discount.where(source: coupon_was).find_each do |adj|
        adj.destroy unless adj.reverted?
      end
      self.embedded_coupon = nil unless coupon.present?
    end
  end

  def can_auto_approve?
    paid? && !approved?
  end

  def execute_auto_approve
    auto_approve_coupon = coupon && coupon.auto_approve?
    approve! if auto_approve_coupon || all_public_work?
    notes.create(message: '用測試用折扣碼，系統自動審核') if auto_approve_coupon
  end

  def all_public_work?
    order_items.all? do |item|
      if item.itemable.is_a? Work
        item.itemable.is_public?
      elsif item.itemable.is_a? StandardizedWork
        item.itemable.published?
      elsif item.itemable.is_a? ArchivedStandardizedWork
        item.itemable.published?
      end
    end
  end

  def become_approved?
    !approved_was && approved?
  end

  def payment_remind
    PaymentRemindSender.perform_in(10.minutes, id) if may_pay? && Region.china?
  end

  def delay_payment?
    DELAY_PAYMENTS.include? payment
  end

  def available_promotions
    Promotion.available
  end

  def avilable_order_level_promotions
    Promotion.started.order_level.select { |p| p.applicable?(self) }
  end

  def available_shipping_fee_promotions
    Promotion.started.shipping_fee.select { |p| p.applicable?(self) }.sort
  end

  def enqueue_calculate_bought_count_for_product_template
    BoughtCountCalculateWorker.perform_async(id)
  end

  def enqueue_calculate_bought_count_for_standardized_work
    StandardizedWorkBoughtCountCalculateWorker.perform_async(id)
  end

  def enqueue_send_payment_notification_from_shop
    StoreOrderPaymentNotificationWorker.perform_async(id)
  end
end
