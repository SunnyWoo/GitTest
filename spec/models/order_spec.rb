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

require 'spec_helper'

describe Order do
  it { is_expected.to be_kind_of(HasUniqueUUID) }
  it_behaves_like 'logcraft trackable'
  let(:trackable) { create(:order) }

  it 'FactoryGirl' do
    expect(build(:order)).to be_valid
  end

  it { should validate_inclusion_of(:payment).in_array(Order.payments) }
  it { should have_many(:order_adjustments) }
  it { should have_many(:item_adjustments) }
  it { should have_many(:adjustments) }

  let(:order) { create(:order) }
  let(:standardized_order) { create(:order, :with_standardized_work) }

  # before do
  #   CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
  #   CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
  # end

  before do
    create_basic_currencies
  end

  context 'aasm_state' do
    it 'start with an initial state' do
      expect(order.aasm.current_state).to eq(:pending)
      expect(order).to respond_to(:pending?)
      expect(order).to be_pending
    end

    it 'transitions pay' do
      expect(order).to respond_to(:pay)
      order.pay
      expect(order.aasm.current_state).to eq(:paid)
      expect(order.paid_at).to_not be_nil
    end

    it 'allow transitions pay' do
      expect(order).to respond_to(:pay)
      order.pay
      expect(order.aasm.current_state).to eq(:paid)
      expect(order).to respond_to(:ship)
    end

    it 'denies transitions pay' do
      order.pay
      expect { order.pay }.to raise_error(AASM::InvalidTransition)
    end

    it 'allow transitions cancel' do
      expect(order).to respond_to(:cancel)
      order.cancel
      expect(order.aasm.current_state).to eq(:canceled)
    end

    it 'denies transitions cancel' do
      order.pay
      expect { order.cancel }.to raise_error(AASM::InvalidTransition)
    end

    it 'allow transitions ship' do
      order.pay
      expect(order).to respond_to(:ship)
      order.ship
      expect(order.aasm.current_state).to eq(:shipping)
    end

    it 'denies transitions ship' do
      order.cancel
      expect { order.ship }.to raise_error(AASM::InvalidTransition)
    end

    it 'allow transitions refund' do
      order.pay
      expect(order).to respond_to(:refund)
      order.refund
      expect(order.aasm.current_state).to eq(:refunded)
    end

    it 'denies transitions refund' do
      order.cancel
      expect { order.refund }.to raise_error(AASM::InvalidTransition)
    end

    it 'allow transitions refund' do
      order.pay
      expect(order).to respond_to(:refund)
      order.refund
      expect(order.aasm.current_state).to eq(:refunded)
    end

    it 'allow transitions refund after part_refund' do
      order.pay
      expect(order).to respond_to(:part_refund)
      order.refund
      expect(order.aasm.current_state).to eq(:refunded)
    end

    it 'enqueues bought count calculate work after payment' do
      order.pay
      assert_equal 1, BoughtCountCalculateWorker.jobs.size
    end

    it 'enqueues standardized_work bought count calculate work after payment' do
      order.pay
      assert_equal 1, StandardizedWorkBoughtCountCalculateWorker.jobs.size
    end

    it 'enqueues enqueue_send_payment_notification_from_shop after payment with store order' do
      order.update_column :source, 2
      order.pay
      assert_equal 1, StoreOrderPaymentNotificationWorker.jobs.size
    end

    it 'does not enqueue enqueue_send_payment_notification_from_shop after payment with non-store order' do
      order.pay
      assert_equal 0, StoreOrderPaymentNotificationWorker.jobs.size
    end

    it 'denies transitions refund' do
      order.cancel
      expect { order.refund }.to raise_error(AASM::InvalidTransition)
    end

    it 'allow transitions part_refund' do
      order.pay
      expect(order).to respond_to(:part_refund)
      order.part_refund
      expect(order.aasm.current_state).to eq(:part_refunded)
    end

    it 'allow transitions part_refund after part_refund' do
      order.pay
      order.part_refund
      expect(order).to respond_to(:part_refund)
      order.part_refund
      expect(order.aasm.current_state).to eq(:part_refunded)
    end

    it 'allow transitions begin_part_refund' do
      order.pay
      order.begin_part_refund
      expect(order.aasm.current_state).to eq(:part_refunding)
      order.part_refund
      expect(order.aasm.current_state).to eq(:part_refunded)
    end

    it 'allow transitions begin_refund' do
      order.pay
      order.begin_refund
      expect(order.aasm.current_state).to eq(:refunding)
      order.refund
      expect(order.aasm.current_state).to eq(:refunded)
    end

    it 'denies transitions part_refund' do
      order.cancel
      expect { order.part_refund }.to raise_error(AASM::InvalidTransition)
    end

    context 'for neweb/atm order' do
      let(:order) { create :order, payment: 'neweb/atm' }
      before { order.prepare_payment }

      it 'transitions prepare_payment' do
        expect(order.aasm.current_state).to eq :waiting_for_payment
      end

      it 'create payment dun job' do
        assert_equal 1, PaymentDun.jobs.size
        expect(order.sms_job_id).not_to be_nil
      end

      it 'create waiting for pay notice job' do
        assert_equal 1, SmsWaitingForPayNoticeWorker.jobs.size
        expect(order.sms_pay_notice_job_id).not_to be_nil
      end

      it 'does not enqueue_send_payment_notification_from_shop with non-store order' do
        assert_equal 0, StoreOrderPaymentNotificationWorker.jobs.size
      end

      context 'should canceled sms pay notice job afrer event pay or cancel' do
        let(:job) { instance_spy('Sidekiq::ScheduledSet', try: true) }
        before { allow(Sidekiq::ScheduledSet).to receive_message_chain('new.find_job').and_return(job) }
        it 'erases sms_job_id after pay!' do
          order.pay
          expect(order.sms_job_id).to be_nil
        end

        it 'erases sms_pay_notice_job_id after pay!' do
          order.pay
          expect(order.sms_pay_notice_job_id).to be_nil
        end

        it 'erases sms_job_id after cancel!' do
          order.cancel
          expect(order.sms_job_id).to be_nil
        end
      end
    end

    context 'for neweb/atm shop order' do
      let(:store) { create :store }
      let(:order) { create :order, payment: 'neweb/atm', source: 2, channel: store.id }
      it 'enqueues send_payment_notification_from_shop_worker with store order' do
        order.prepare_payment
        assert_equal 1, StoreOrderPaymentNotificationWorker.jobs.size
      end
    end
  end

  context 'work_state' do
    it 'order initial' do
      expect(order.pending?).to be true
    end

    it 'order item to printed' do
      order.reload
      order.order_items.first.print
      expect(order.working?).to be true
    end

    it 'order aasm_state to shipping' do
      order.reload
      order.pay
      order.order_items.first.print
      order.ship
      expect(order.finish?).to be true
    end
  end

  context 'paper_trail' do
    it 'version check' do
      with_versioning do
        order = create :order
        first_version_size = order.versions.size
        expect(first_version_size).not_to eq 0
        order.update_attribute(:currency, 'TWD')
        expect(order.versions.size).to be > first_version_size
      end
    end
  end

  context 'render Taiwan New Dollar price' do
    it 'render_twd_price' do
      price = order.price
      expect(order.render_twd_price).to eq(price * 30)
    end
  end

  context 'order report' do
    it 'after pay, report to redis' do
      order.reload
      order.pay
      expect($redis.smembers('reports:update_dates').size).not_to eq(0)
    end

    it 'after cancel, report to redis' do
      order.reload
      order.cancel
      expect($redis.smembers('reports:update_dates').size).not_to eq(0)
    end

    it 'update aasm_state, report to redis' do
      order.reload
      order.update aasm_state: :canceled
      expect($redis.smembers('reports:update_dates').size).not_to eq(0)
    end
  end

  context 'billing_info and shipping_info' do
    before do
      order.reload
    end
    it 'check billing_info' do
      expect(order.billing_info).not_to be nil
      expect(order.billing_info.type).to eq('BillingInfo')
    end

    it 'check shipping_info' do
      expect(order.shipping_info).not_to be nil
      expect(order.shipping_info.type).to eq('ShippingInfo')
    end
  end

  context 'caculate_price' do
    it 'stores all feea for order' do
      order.reload.calculate_price!
      expect(order.subtotal).to eq(BigDecimal.new('99.9'))
      expect(order.discount).to eq(BigDecimal.new('0.0'))
      expect(order.shipping_fee).to eq(BigDecimal.new('0.0'))
      expect(order.price).to eq(99.9)
    end

    it 'coupon price Greater Than order price ' do
      order.reload.calculate_price!
      expect(order.price).to eq(99.9)

      coupon = create(:coupon, price_table: { 'USD' => 120 })
      order.coupon = coupon
      order.calculate_price!

      expect(order.price).to eq(0)
    end
  end

  context 'approving' do
    before do
      order.reload
      standardized_order.reload
    end

    context '#approve' do
      it 'is false by default' do
        expect(order.approved).to be(false)
        expect(PrintItem.count).to eq(0)
      end
    end

    describe '#approve!' do
      it 'sets approve to true and ' do
        order.approve!
        expect(order.approved).to be(true)
        expect(order.flags).not_to include(:external_transfer)
      end

      it 'after approved deliver_order_to_remote' do
        allow(order).to receive(:have_deliver_order_items?).and_return(true)
        expect { order.approve! }.to change { DeliverOrderWorker.jobs.size }.by(1)
      end

      it 'when approved false deliver_order_to_remote' do
        allow(order).to receive(:approve!).and_return(false)
        expect { order.approve! }.to change { DeliverOrderWorker.jobs.size }.by(0)
      end

      it 'builds print items' do
        order.approve!
        expect(PrintItem.count).to eq(1)
      end

      context 'with StandardizedWork' do
        it 'builds print items' do
          standardized_order.approve!
          expect(PrintItem.count).to eq(2)
        end
      end

      it 'creates "approved" activity' do
        order.approve!
        activity = order.activities.last
        expect(activity.key).to eq('approved')
      end

      it 'updates flags with external_transfer' do
        order_item = create(:order_item).tap { |i| i.stub(:external_production?).and_return(true) }
        order.order_items << order_item
        order.approve!
        expect(order.flags).to include(:external_transfer)
      end

      it 'watch order when have message' do
        order_item = create(:order_item).tap { |i| i.stub(:external_production?).and_return(true) }
        order.order_items << order_item
        order.update_column(:message, 'message')
        order.approve!
        expect(order.watching).to eq(true)
      end
    end
  end

  describe '#payment_id' do
    it 'sets payment_id and payment_info.id' do
      order = create(:order)
      order.payment_id = '9977553311'
      order.save
      order.reload
      expect(order.payment_id).to eq('9977553311')
      expect(order[:payment_id]).to eq('9977553311')
      expect(order.payment_info['payment_id']).to eq('9977553311')
    end
  end

  describe '#payment' do
    it 'sets payment and payment_info.method' do
      order = create(:order)
      order.payment = 'paypal'
      order.save
      order.reload
      expect(order.payment).to eq('paypal')
      expect(order[:payment]).to eq('paypal')
      expect(order.payment_info['method']).to eq('paypal')
    end
  end

  describe '#payment_method' do
    it 'sets payment and payment_info.method' do
      order = create(:order)
      order.payment_method = 'paypal'
      order.save
      order.reload
      expect(order[:payment]).to eq('paypal')
      expect(order.payment_info['method']).to eq('paypal')
    end
  end

  context 'StandardizedWork' do
    it 'works with standardized_work' do
      standardized_order.reload.calculate_price!
      # 因為 Factory 中有 after_create 建立一筆 normal order_item, 所以金額是兩筆的價錢
      expect(standardized_order.price).to eq(199.8)

      coupon = create(:coupon, price_table: { 'USD' => 200 })
      standardized_order.send(:check_and_assign_coupon, coupon.code)
      standardized_order.calculate_price!

      expect(standardized_order.price).to eq(0)

      coupon = Coupon.find_coupon(coupon.code)

      expect(coupon.reload).to be_is_used
      expect(order.reload.aasm_state).not_to eq 'paid'

      build(:order, :with_standardized_work)
      standardized_order.send(:check_and_assign_coupon, coupon.code)
      expect(standardized_order.errors).not_to be_blank
    end

    it 'coupon price Greater Than order price ' do
      order.calculate_price!

      expect(order.price).to eq(99.9)
      coupon = create(:coupon, price_table: { 'USD' => 120 })
      order.coupon = coupon
      order.calculate_price!
      expect(order.price).to eq(0)
    end
  end

  it 'does set coupon code to be used when creating an order' do
    order.reload.calculate_price!
    expect(order.price).to eq(99.9)

    coupon = create(:coupon, price_table: { 'USD' => 120 })
    order.send(:check_and_assign_coupon, coupon.code)
    order.calculate_price!

    expect(order.price).to eq(0)
    coupon = Coupon.find_coupon(coupon.code)
    expect(coupon.reload).to be_is_used
    expect(order.reload.aasm_state).not_to eq 'paid'

    build(:order)
    order.send(:check_and_assign_coupon, coupon.code)
    expect(order.errors).not_to be_blank
  end

  it 'does increase coupon usage count when creating an order with coupon' do
    coupon = create(:coupon)
    expect { create(:order, coupon: coupon) }.to change { coupon.usage_count }.by(1)
  end

  context 'check payment,when is cash_on_delivery' do
    it 'shipping_way is cash_on_delivery' do
      order.reload
      order.payment = 'cash_on_delivery'
      shipping_info = order.shipping_info
      shipping_info.shipping_way = 'cash_on_delivery'
      order.save
      expect(order.payment).to eq('cash_on_delivery')
      expect(order.shipping_info_shipping_way).to eq('cash_on_delivery')
    end

    it 'shipping_way is standard' do
      order.reload
      order.payment = 'cash_on_delivery'
      shipping_info = order.shipping_info
      shipping_info.shipping_way = 'standard'
      order.save
      expect(order.payment).to eq('cash_on_delivery')
      expect(order.shipping_info_shipping_way).to eq('cash_on_delivery')
    end
  end

  context '#can_refund?' do
    it 'returns true if refund price > 0' do
      paid_order = create :paid_order
      paid_order.reload.calculate_price!

      price = paid_order.price
      refund_amount = price * 0.5

      expect(paid_order.price_after_refund > 0).to eq true
      expect(paid_order.can_refund?).to eq true

      paid_order.refunds.create amount: refund_amount

      expect(paid_order.price_after_refund > 0).to eq true
      expect(paid_order.can_refund?).to eq true
    end

    it 'returns false if refund price < 0' do
      paid_order = create :paid_order
      paid_order.reload.calculate_price!

      price = paid_order.price
      refund_amount = price * 2

      paid_order.refunds.create amount: refund_amount

      expect(paid_order.price_after_refund).to be < 0
      expect(paid_order.can_refund?).to be false
    end

    it 'returns false if refund price = 0' do
      paid_order = create(:paid_order).tap(&:reload).tap(&:save)
      price = paid_order.price
      refund_amount = price
      paid_order.refunds.create amount: refund_amount

      expect(paid_order.price_after_refund).to eq 0
      expect(paid_order.can_refund?).to be false
    end
  end

  context '#price_after_refund' do
    it 'returns order.price if no refund created' do
      order.calculate_price!
      expect(order.price_after_refund).to eq order.price
    end

    it 'returns price that has to be reduced if refund created' do
      order.reload.calculate_price!

      order.refunds.create amount: 25
      expect(order.price_after_refund).to eq order.price - 25

      order.refunds.create amount: 50
      expect(order.price_after_refund).to eq(24.9) # order.price - 25 - 50
    end

    context 'standardize work' do
      it 'returns price that has to be reduced if refund created' do
        standardized_order.reload.calculate_price!

        standardized_order.refunds.create amount: 25
        expect(standardized_order.price_after_refund).to eq standardized_order.price - 25

        standardized_order.refunds.create amount: 50
        expect(standardized_order.price_after_refund).to eq(124.8) # standardized_order.price - 25 - 50
      end
    end
  end

  it 'cannot creates order if coupon condition is not satisfied' do
    coupon = create(:rule_coupon, coupon_rules: [create(:threshold_rule, threshold_price_table: { 'USD' => 100 })])
    expect(build(:order, :with_standardized_work, coupon: coupon)).to be_invalid
  end

  context '#is_need_create_invoice?' do
    it 'order shipping to US' do
      expect(order.shipping_info_country_code).to eq('US')
      expect(order.is_need_create_invoice?).to be true
    end

    it 'order shipping to TW' do
      order = create(:shipping_to_tw_order)
      expect(order.shipping_info_country_code).to eq('TW')
      expect(order.is_need_create_invoice?).to be true
    end
  end

  context '#approve!' do
    let(:order) { create :order }
    before do
      # create_basic_currencies
      create :iphone6_order_item, quantity: 3, order: order
    end

    context 'when an order did approve!' do
      it 'returns true if order_items create the correct number of print_items' do
        order.reload.approve!
        expect(order.print_items_count).to eq order.reload.print_items.count
      end

      context 'when contains auto-imposite product models' do
        it 'enqueues imposite and upload' do
          order.order_items(true).first.itemable.product.update(auto_imposite: true)
          expect_any_instance_of(ProductModel).to receive(:enqueue_imposite_and_upload)
          order.approve!
        end
      end

      context 'when does not contains auto-imposite product models' do
        it 'does not enqueues imposite and upload' do
          order.order_items(true).first.itemable.product.update(auto_imposite: false)
          expect_any_instance_of(ProductModel).to_not receive(:enqueue_imposite_and_upload)
          order.approve!
        end
      end
    end
  end

  context '#execute_auto_approve' do
    let(:pending_order) { create :pending_order }
    it 'does nothing if order is pending' do
      pending_order.update shipping_fee: 30.0
      expect(pending_order.reload.approved).to eq false
    end

    context 'if order is paid' do
      it 'auto approves order with auto_approved coupon used' do
        coupon = create :coupon, auto_approve: true
        order = create :order, coupon: coupon
        order.reload
        order.pay!
        order.reload
        expect(order.order_items.exists?).to eq true
        expect(order.approved).to eq true
        expect(order.print_items.count).to eq(order.order_items.count)
        expect(order.notes.last.message).to match '用測試用折扣碼，系統自動審核'
      end

      it 'auto approves order with public work' do
        order = build :order, :with_public_work
        order.save
        order.reload
        order.pay!
        expect(order.order_items.exists?).to eq true
        expect(order.approved).to eq true
        expect(order.print_items.count).to eq(order.order_items.count)
      end

      it 'auto approves order with standardized work' do
        order = build :order, :with_standardized_work
        order.save
        order.reload
        order.pay!
        expect(order.order_items.exists?).to eq true
        expect(order.approved).to eq true
        expect(order.print_items.count).to eq(order.order_items.count)
      end

      it 'does not auto approve order with normal coupon used' do
        coupon = create :coupon
        order = create :order, coupon: coupon
        order.reload
        order.pay!
        expect(order.approved).to eq false
      end

      it 'does not auto approve order without coupon used' do
        order = create :order
        order.reload
        order.pay!
        expect(order.approved).to eq false
      end
    end
  end

  context '#reconciliation' do
    before do
      @order_with_cash_on_delivery = create(:order, :with_cash_on_delivery)
      @order_with_atm = create(:order, :with_atm)
    end

    it 'execute reconciliation' do
      expect(Order.not_yet_paid.count).to eq(2)
      allow(HTTParty).to receive(:post).and_return(response = double(:response))
      allow_any_instance_of(NewebService).to receive(:parse_query)
        .with(response).and_return('rc' => '-4', 'rc2' => '72')
      Order.reconciliation
      expect(Order.not_yet_paid.count).to eq(1)
      expect(Order.not_yet_paid.first.payment).to eq('cash_on_delivery')
    end
  end

  describe '#pingpp_alipay_payment' do
    context 'with pingpp_alipay' do
      Given(:order) { create(:order, :with_pingpp_alipay) }
      Then { order.pingpp_alipay_payment? }
    end

    context 'with pingpp_wx' do
      Given(:order) { create(:order, :with_pingpp_wx) }
      Then { order.pingpp_alipay_payment? == false }
    end
  end

  describe '#order_payment_note_time' do
    context 'returns 12:00 three days later if Time.zone.now.hour > 12' do
      Given(:order) { create :order }
      When(:time) { Time.zone.local(2015, 1, 1, 15, 0) }
      Then { expect(order.send(:order_payment_note_time, time)).to eq Time.zone.local(2015, 1, 4, 12, 0) }
    end

    context 'returns 12:00 two days later if Time.zone.now.hour < 12' do
      Given(:order) { create :order }
      When(:time) { Time.zone.local(2015, 1, 1, 9, 0) }
      Then { expect(order.send(:order_payment_note_time, time)).to eq Time.zone.local(2015, 1, 3, 12, 0) }
    end
  end

  describe '#currency_price' do
    Given(:order1) { Order.new(price: 30.22, currency: 'CNY') }
    Given(:order2) { Order.new(price: 300, currency: 'TWD') }
    Then { order1.currency_price('TWD') == 151 }
    And { order2.currency_price('CNY') == 60.0 }
  end

  describe '#cancel_payment_dun' do
    context 'on functionality' do
      Given!(:order) { create :order, sms_job_id: 'Darth Vader' }
      context 'it should cancel_sms_job when sms_job_id is available in Sidekiq' do
        Given(:job) { instance_spy('Sidekiq::ScheduledSet', try: true) }
        When { expect(Sidekiq::ScheduledSet).to receive_message_chain('new.find_job').and_return(job) }
        When { order.send(:cancel_payment_dun) }
        Then { order.sms_job_id.nil? }
        And { order.activities.last.key.to_sym == :cancel_sms_job }
      end

      context 'it should not clean sms_job_id when sms_job_id is unavailable in Sidekiq' do
        When { order.send(:cancel_payment_dun) }
        Then { order.sms_job_id == 'Darth Vader' }
        And { order.activities.last.key.to_sym == :sms_job_missing }
      end
    end

    context 'when directly updates aasm_state rather than through aasm_state event' do
      Given!(:order) { create :order, aasm_state: 'waiting_for_payment', sms_job_id: 'Yoda' }
      Given(:job) { instance_spy('Sidekiq::ScheduledSet', try: true) }
      When { allow(Sidekiq::ScheduledSet).to receive_message_chain('new.find_job').and_return(job) }
      context 'it should be invoked when aasm_state change from waiting_for_payment to paid' do
        When { order.update aasm_state: 'paid' }
        Then { order.sms_job_id.nil? }
        And { order.activities(true).map(&:key).include? 'cancel_sms_job' }
      end

      context 'it should be invoked when aasm_state change from waiting_for_payment to canceld' do
        When { order.update aasm_state: 'canceled' }
        Then { order.sms_job_id.nil? }
        And { order.activities(true).map(&:key).include? 'cancel_sms_job' }
      end

      context 'it does nothing without sms_job_id' do
        Given!(:order) { create :order, aasm_state: 'waiting_for_payment' }
        When { order.update aasm_state: 'canceled' }
        Then { order.sms_job_id.nil? }
        And { order.activities(true).map(&:key).exclude? 'cancel_sms_job' }
      end
    end
  end

  describe '#calculate_price!' do
    describe 'simple coupon' do
      Given(:coupon) { create :percentage_coupon }
      Given(:work) { create :work, :with_special_price }
      Given(:order_item) { create :order_item, itemable: work }
      Given(:order) do
        create(:order, currency: 'TWD').tap do |o|
          o.order_items = [order_item]
          o.coupon = coupon
          o.save!
        end
      end
      When { order.calculate_price! }
      Then { order.discount == order_item.price_in_currency('TWD') * coupon.percentage }
      And { order.discount == order_item.discount }
    end

    describe '#apply_count_limit coupon' do
      Given(:order) do
        create(:order, currency: 'TWD').tap do |o|
          o.order_items = [order_item1, order_item2]
          o.coupon = coupon
          o.save!
        end
      end
      context 'when apply_count_limit is limit' do
        Given(:work) { create :work, :with_special_price }
        Given(:order_item1) { create :order_item, itemable: work }
        Given(:order_item2) { create :order_item, itemable: work }
        Given(:coupon) {
          create :coupon, apply_count_limit: 1, condition: 'rules',
                          coupon_rules: [create(:product_model_rule, product_model_ids: [work.product.id])]
        }
        When { order.calculate_price! }
        Then { order.discount == order_item1.discount }
        Then { order_item2.discount.to_f == 0 }
      end

      context 'when apply_count_limit is no limit' do
        Given(:coupon) { create :percentage_coupon, apply_count_limit: -1 }
        Given(:work) { create :work, :with_special_price }
        Given(:order_item1) { create :order_item, itemable: work }
        Given(:order_item2) { create :order_item, itemable: work }
        When { order.calculate_price! }
        Then { order.discount == order_item1.discount + order_item2.discount }
      end
    end
  end

  describe '#payment_remind callback' do
    context 'send email when form china and not paid' do
      before { allow(Region).to receive(:china?).and_return(true) }
      Given(:order) { create :order }
      When { order.save }
      Then { PaymentRemindSender.jobs.size == 1 }
    end

    context 'not send email when form china and paid' do
      before { allow(Region).to receive(:china?).and_return(true) }
      Given(:order) { create :order, aasm_state: 'paid' }
      When { order.save }
      Then { PaymentRemindSender.jobs.size == 0 }
    end

    context 'not send email when form global and not paid' do
      before { allow(Region).to receive(:global?).and_return(true) }
      Given(:order) { create :order }
      When { order.save }
      Then { PaymentRemindSender.jobs.size == 0 }
    end
  end

  describe '#user_usage_count_limit coupon' do
    context 'when user_usage_count_limit is limit' do
      Given(:user1) { create :user }
      Given(:user2) { create :user }
      Given(:coupon) {
        create :coupon, usage_count_limit: -1,
                        user_usage_count_limit: 1
      }
      Given!(:order) { create :order, user: user1, coupon: coupon }
      When { order.pay! }
      Then { coupon.can_use?(user1) == false }
      And { coupon.can_use?(user2) == true }
    end

    context 'when user_usage_count_limit is no limit' do
      Given(:user1) { create :user }
      Given(:user2) { create :user }
      Given(:coupon) {
        create :coupon, usage_count_limit: -1,
                        user_usage_count_limit: -1
      }
      Given!(:order) { create :order, user: user1, coupon: coupon }
      Then { coupon.can_use?(user1) == true }
      And { coupon.can_use?(user2) == true }
    end
  end

  describe '#print_items_count' do
    # 被持久化后, print items的计算方式排除抛单的work
    context 'when order is persisted' do
      Given(:order) { create :order }
      Then { order.reload.print_items_count == 1 }
    end
  end

  describe '.build_for_api_pricing' do
    Given(:work) { create(:work) }
    Given(:user) { create(:user) }
    Given(:product_key){ create(:product_model).key }
    Given(:mock_order) { double(Order) }
    Given(:item_create){
      {
        type: 'create',
        product_model_key: product_key,
        quantity: 3
      }
    }
    Given(:item_shop){
      {
        type: 'shop',
        work_uuid: work.uuid,
        quantity: 2
      }
    }
    Given(:params) do
      {
        currency: 'USD',
        order_items: items_params,
        shipping_info: {
          shipping_way: 'standard'
        }
      }.with_indifferent_access
    end
    Given(:order) { Order.build_for_api_pricing!(user, params) }
    Given(:items_params) { [item_create] }
    context 'success cases' do
      context 'with items created by customer' do
        Then { order.currency == 'USD' }
        And { order.order_items.size == 1 }
        And { order.order_items.first.quantity == 3 }
        And { order.order_items.first.itemable.product_key == product_key }
        And { order.shipping_info.shipping_way == 'standard' }
        And { order.sub_total == (99.9 * 3).round(4) }
        And { order.price == (99.9 * 3).round(4) }
      end

      context 'with items bought from shop' do
        Given(:items_params) { [item_shop] }
        Then { order.currency == 'USD' }
        And { order.order_items.size == 1 }
        And { order.order_items.first.quantity == 2 }
        And { order.order_items.first.itemable == work }
        And { order.shipping_info.shipping_way == 'standard' }
        And { order.sub_total == 99.9 * 2 }
        And { order.price == 99.9 * 2 }
      end

      context 'with coupon' do
        Given(:items_params) { [item_create, item_shop] }
        Given(:coupon) { create(:coupon) }
        When { params[:coupon] = coupon.code }
        Then { order.currency == 'USD' }
        And { order.order_items.size == 2 }
        And { order.order_items.first.quantity == 3 }
        And { order.order_items.first.itemable.product_key == product_key }
        And { order.order_items.last.quantity == 2 }
        And { order.order_items.last.itemable == work }
        And { order.shipping_info.shipping_way == 'standard' }
        And { order.coupon == coupon }
        And { order.sub_total == 99.9 * 5 }
        And { order.discount == 5 }
        And { order.price == (99.9 * 5) - 5 }
      end
    end

    context 'failure cases' do
      context 'empty items' do
        Given(:items_params) { [] }
        Then do
          expect {
            Order.build_for_api_pricing!(user, params)
          }.to raise_error(ApplicationError, "order_items can't be blank")
        end
      end
      context 'invalid coupon' do
        Given(:coupon_code){ 'xx' }
        Given(:params_with_invalid_coupon){ params.merge(coupon: coupon_code) }
        Then do
          expect {
            Order.build_for_api_pricing!(user, params_with_invalid_coupon)
          }.to raise_error(InvalidCouponError)
        end
      end
    end
  end

  context '#enqueue_nuandao_order_shipping' do
    it 'when order change aasm_state and payment != nuandao_b2b ' do
      assert_equal 0, NuandaoOrderShippingWorker.jobs.size
      order.pay
      assert_equal 0, NuandaoOrderShippingWorker.jobs.size
    end

    it 'when order change aasm_state and payment == nuandao_b2b ' do
      order.update(payment: 'nuandao_b2b')
      assert_equal 0, NuandaoOrderShippingWorker.jobs.size
      order.pay
      assert_equal 1, NuandaoOrderShippingWorker.jobs.size
    end
  end

  context 'mark_merge_ready' do
    context 'when order is paid' do
      Given!(:order1) { create :order, aasm_state: 'paid', shipping_fee: 0.0 }
      Given!(:order2) { create :order, shipping_fee: 0.0 }
      before do
        order1.shipping_info = create :shipping_info, name: 'angel', phone: '110', address: 'shanghai commandp'
        order1.save
        order2.shipping_info = create :shipping_info, name: 'angel', phone: '110', address: 'shanghai commandp'
        order2.save
      end
      When { order2.pay! }
      Then { order1.reload.merge_target_ids.sort == [order1.id, order2.id].sort }
      And { order1.flags.include? :combined_shipping }
      And { order2.reload.merge_target_ids.sort == [order1.id, order2.id].sort }
      And { order2.flags.include? :combined_shipping }
    end

    context 'when order shipping fee not free' do
      Given!(:order1) { create :order, aasm_state: 'paid' }
      Given!(:order2) { create :order, aasm_state: 'paid' }
      Given!(:order3) { create :order }
      before do
        order1.shipping_info = create :shipping_info, name: 'angel', phone: '110', address: 'shanghai commandp'
        order1.save
        order2.shipping_info = create :shipping_info, name: 'angel', phone: '110', address: 'shanghai commandp'
        order2.save
        order3.shipping_info = create :shipping_info, name: 'angel', phone: '110', address: 'shanghai commandp'
        order3.save
        order1.update_columns(shipping_fee_discount: 8.0)
        order2.update_columns(shipping_fee_discount: 8.0)
        order3.update_columns(shipping_fee_discount: 0.0)
      end
      When { order3.reload.pay! }
      Then { order3.reload.merge_target_ids.blank? }
    end

    context 'when merge_targets less than two' do
      Given!(:order) { create :order }
      before do
        order.shipping_info = create :shipping_info, name: 'angel', phone: '110', address: 'shanghai commandp'
        order.save
      end
      When { order.reload.pay! }
      Then { order.reload.merge_target_ids.blank? }
    end
  end

  context '#ship_strategy' do
    context 'when order items is all shipping' do
      Given(:order) { create :order, aasm_state: :paid }
      before { allow(order).to receive(:order_items_all_shipping?).and_return(true) }
      When { order.ship_strategy }
      Then { order.reload.shipping? }
      And { order.shipping_state == 'all_shipping' }
    end

    context 'when order items is not all shipping' do
      Given(:order) { create :order, aasm_state: :paid }
      before { allow(order).to receive(:order_items_all_shipping?).and_return(false) }
      When { order.ship_strategy }
      Then { order.shipping_state == 'part_shipping' }
      And { order.activities.last.key == 'part_shipped' }
    end
  end

  context '#can_be_packaged_all?' do
    Given!(:order) { create :order }
    Given!(:order_item) { create :order_item, order: order, aasm_state: :pending }
    Given!(:print_item1) { create :print_item, order_item: order_item, aasm_state: :pending }
    Given!(:print_item2) { create :print_item, order_item: order_item, aasm_state: :received }
    context 'return true' do
      When { order.reload.print_items.update_all(aasm_state: :received) }
      Then { order.reload.can_be_packaged_all? == true }
    end

    context 'return false' do
      Then { order.reload.can_be_packaged_all? == false }
    end
  end

  context '#package_strategy' do
    context 'when order items is all onboard' do
      Given(:order) { create :order, aasm_state: :paid }
      before { allow(order).to receive(:order_items_all_onboard?).and_return(true) }
      When { order.package_strategy }
      Then { order.packaging_state == 'all_packaged' }
      And { order.activities.last.key == 'all_packaged' }
    end

    context 'when order items is not all onboard' do
      Given(:order) { create :order, aasm_state: :paid }
      before { allow(order).to receive(:order_items_all_onboard?).and_return(false) }
      When { order.package_strategy }
      Then { order.packaging_state == 'part_packaged' }
      And { order.activities.last.key == 'part_packaged' }
    end
  end

  context '#enqueue_cancel_order' do
    it 'when create order enqueue CancelOrderWorker' do
      assert_equal 0, CancelOrderWorker.jobs.size
      order
      assert_equal 1, CancelOrderWorker.jobs.size
      expect(order.cancel_order_job_id).not_to be_nil
      expect(order.activities.where(key: :create_cancel_order_job).count).to eq(1)
    end

    it 'when aasm_state is not pending, not to enqueue CancelOrderWorker' do
      assert_equal 0, CancelOrderWorker.jobs.size
      order = create(:paid_order)
      assert_equal 0, CancelOrderWorker.jobs.size
      expect(order.cancel_order_job_id).to be_nil
      expect(order.activities.where(key: :create_cancel_order_job).count).to eq(0)
    end

    it 'when payment is neweb/atm not enqueue CancelOrderWorker' do
      assert_equal 0, CancelOrderWorker.jobs.size
      order = create(:order, :with_atm)
      assert_equal 0, CancelOrderWorker.jobs.size
      expect(order.cancel_order_job_id).to be_nil
      expect(order.activities.where(key: :create_cancel_order_job).count).to eq(0)
    end

    it 'when payment is neweb/mmk not enqueue CancelOrderWorker' do
      assert_equal 0, CancelOrderWorker.jobs.size
      order = create(:order, :with_mmk)
      assert_equal 0, CancelOrderWorker.jobs.size
      expect(order.cancel_order_job_id).to be_nil
      expect(order.activities.where(key: :create_cancel_order_job).count).to eq(0)
    end
  end

  context '#cancel_order_worker' do
    before do
      @order = create(:order)
      job = instance_spy('Sidekiq::ScheduledSet', try: true)
      expect(Sidekiq::ScheduledSet).to receive_message_chain('new.find_job').and_return(job)
    end

    it 'when order event pay!' do
      expect(@order.cancel_order_job_id).not_to be_nil
      @order.pay!
      expect(@order.cancel_order_job_id).to be_nil
      expect(@order.activities.where(key: :cancel_cancel_order_job).count).to eq(1)
    end

    it 'when order update aasm_state to paid' do
      expect(@order.cancel_order_job_id).not_to be_nil
      @order.update(aasm_state: 'paid')
      expect(@order.cancel_order_job_id).to be_nil
      expect(@order.activities.where(key: :cancel_cancel_order_job).count).to eq(1)
    end

    it 'when order event cancel!' do
      expect(@order.cancel_order_job_id).not_to be_nil
      @order.cancel!
      expect(@order.cancel_order_job_id).to be_nil
      expect(@order.activities.where(key: :cancel_cancel_order_job).count).to eq(1)
    end

    it 'when order update aasm_state to canceled' do
      expect(@order.cancel_order_job_id).not_to be_nil
      @order.update(aasm_state: 'canceled')
      expect(@order.cancel_order_job_id).to be_nil
      expect(@order.activities.where(key: :cancel_cancel_order_job).count).to eq(1)
    end
  end

  context '#check_coupon' do
    context 'when coupon code is MUGSH0000' do
      Given(:china_factory_coupon) { create :coupon, code: 'MUGSH0000' }
      When { order.update(coupon: china_factory_coupon) }
      Then { order.notes.where(message: '中國工廠測試生產用，請直接審核，工廠無需製作').count == 1 }
    end
  end

  context '#changing_coupon' do
    before do
      @before_coupon = create(:coupon)
      @after_coupon = create(:coupon)
    end

    it 'when order chagne coupon' do
      order.update(coupon: @before_coupon)
      expect(order.embedded_coupon.code).to eq(@before_coupon.code)
      expect(@before_coupon.can_use?(order.user)).to be(false)
      expect(@after_coupon.can_use?(order.user)).to be(true)

      order.update(coupon: @after_coupon)
      expect(order.embedded_coupon.code).to eq(@after_coupon.code)
      @before_coupon.reload
      expect(@after_coupon.can_use?(order.user)).to be(false)

      expect(@before_coupon.can_use?(order.user)).to be(true)
      expect(@before_coupon.orders.where(id: order.id).count).to be(0)
    end

    it 'when order chagne coupon, embedded_coupon should be nil' do
      order = create(:order, :with_standardized_work, coupon: @before_coupon)
      order.calculate_price!
      expect(order.embedded_coupon.code).to eq(@before_coupon.code)
      expect(order.price).to eq(99.9 + 94.9)

      order.reload

      order.coupon = nil
      order.calculate_price!
      expect(order.embedded_coupon).to be_nil
      expect(order.price).to eq(99.9 * 2)
    end
  end

  context '#update order info' do
    context 'update order info' do
      Given(:order_item) { create :order_item }
      Given(:remote_info) do
        {
          order: { order_no: '123456789CN',
                   work_state: 'ongoing',
                   aasm_state: 'paid',
                   remote_id: '1' },
          order_items: [{ id: order_item.id, aasm_state: 'sublimated' }]
        }
      end
      Given(:order) { create :order, order_items: [order_item] }
      When { order.update_remote_info(remote_info) }
      Then { order.reload.remote_info == remote_info[:order].as_json }
      And { order_item.reload.remote_info['aasm_state'] == 'sublimated' }
    end
  end

  describe '#notifiable?' do
    context 'payment with nuandao' do
      Given(:order) { create :order, :with_nuandao_b2b, aasm_state: :paid }
      Then { expect(order).not_to be_notifiable }
    end

    context 'other payment methods' do
      Given(:order) { create :order, :with_stripe, aasm_state: :paid }
      Then { expect(order).to be_notifiable }
    end
  end

  describe '#base_price_type' do
    context 'order had a coupon' do
      context 'with discount of original price' do
        Given(:coupon) { create :percentage_coupon, base_price_type: 'original' }
        Given(:order) { create :order, coupon: coupon }
        Then { expect(order.base_price_type).to eq 'original' }
      end

      context 'with discount of special price' do
        Given(:coupon) { create :percentage_coupon, base_price_type: 'special' }
        Given(:order) { create :order, coupon: coupon }
        Then { expect(order.base_price_type).to eq 'special' }
      end
    end

    context 'order had no coupon' do
      Given(:order) { create :order, coupon: nil }
      Then { expect(order.base_price_type).to eq 'special' }
    end
  end

  context '#item_adjustments' do
    it { expect(order.item_adjustments).to eq([]) }
    it 'return order_item adjustments' do
      adjustment = create(:adjustment, order: standardized_order, source: standardized_order.order_items.first)
      expect(standardized_order.item_adjustments).to eq([adjustment])
    end
  end

  context '#remove_coupon' do
    let(:order_with_coupon) { create(:order, :priced, :with_coupon) }

    it 'return nil when coupon is nil' do
      expect(order.remove_coupon).to be_nil
      expect(order.order_adjustments.count).to eq(0)
    end

    it 'return nil when aasm_state is paid' do
      order_with_coupon.update(aasm_state: :paid)
      expect(order_with_coupon.remove_coupon).to be_nil
      expect(order_with_coupon.order_adjustments.count).to eq(1)
    end

    it 'return true when coupon is present' do
      expect(order_with_coupon.remove_coupon).to be_truthy
      expect(order_with_coupon.coupon).to be_nil
      expect(order_with_coupon.embedded_coupon).to be_nil
      expect(order_with_coupon.activities.where(key: 'remove_coupon').count).to eq(1)
    end
  end

  describe '#adjustments_coupon_revert!' do
    Given!(:order_with_coupon) { create(:order, :priced, :with_coupon) }
    Given!(:coupon) { order_with_coupon.coupon }
    Given(:coupon_adjustments) { order_with_coupon.adjustments.where(source: coupon) }
    Given(:first) { coupon_adjustments.first }
    Given(:second) { coupon_adjustments.second }
    Given { order.calculate_price! }
    When { order_with_coupon.adjustments_coupon_revert! }
    Then { expect(coupon_adjustments.count).to eq(2) }
    And { expect(first.source).to eq(second.source) }
    And { expect(second.event).to eq('fallback') }
    And { expect(first.value).to eq(second.value * -1) }
  end

  context '#china_archive_attributes' do
    Given(:order) { create :order }
    before do
      allow(order).to receive(:need_deliver_order_items).and_return([])
    end
    Given(:result) do
      { order_id: order.id, order_no: order.order_no,
        payment: order.payment, order_items: [], single_item: true }
    end

    Then { order.china_archive_attributes == result }
  end

  context '#delete_merge_target_ids' do
    Given(:order) { create :order }
    Given(:order2) { create :order }

    context 'merge_target_ids size <= 2' do
      before do
        order.update(merge_target_ids: [order.id, order2.id])
        order2.update(merge_target_ids: [order.id, order2.id])
      end
      When { order.send(:delete_merge_target_ids) }

      Then { order.reload.merge_target_ids.blank? }
      And { order2.reload.merge_target_ids.blank? }
    end

    context 'merge_target_ids size > 2' do
      Given(:order3) { create :order }
      before do
        order.update(merge_target_ids: [order.id, order2.id, order3.id])
        order2.update(merge_target_ids: [order.id, order2.id, order3.id])
        order3.update(merge_target_ids: [order.id, order2.id, order3.id])
      end
      When { order.send(:delete_merge_target_ids) }

      Then { order.reload.merge_target_ids.blank? }
      And { order2.reload.merge_target_ids == [order2.id, order3.id] }
      And { order3.reload.merge_target_ids == [order2.id, order3.id] }
    end
  end

  context '#paid_at' do
    Given(:order) { create :order, :with_standardized_work }
    When { order.pay! }
    Then { expect(order.reload.paid_at).to be_a(ActiveSupport::TimeWithZone) }
  end

  context '#check_payment' do
    Given(:order) { create :order }

    context 'when payment is nuandao_b2b' do
      When { order.update payment: 'nuandao_b2b' }
      Then { order.source == 'b2b' }
      And { order.channel == 'nuandao' }
    end

    context 'when payment is stripe' do
      When { order.update payment: 'stripe' }
      Then { order.source == 'commandp' }
      And { order.channel.nil? }
    end
  end

  context '#calculate_bought_count_for_product_template' do
    Given(:product_template) { create :product_template }
    context 'does not calculate product template bought_count when order excludes it' do
      Given(:order) { create :order, :with_standardized_work }
      When { order.send :calculate_bought_count_for_product_template }
      Then { product_template.reload.bought_count == 0 }
    end

    context 'calculates product template bought_count when order includes it' do
      Given(:work) { create :work, product_template: product_template }
      Given(:order) { create :order }
      When do
        order.order_items.create itemable: work, quantity: 2
        order.send :calculate_bought_count_for_product_template
      end
      Then { product_template.reload.bought_count == 2 }
    end
  end

  context '#calculate_bought_count_for_standardized_work' do
    Given(:standardized_work) { create :standardized_work }
    context 'does not calculate standardized_work bought_count when order excludes it' do
      Given(:order) { create :order, :with_public_work }
      When { order.send :calculate_bought_count_for_standardized_work }
      Then { standardized_work.reload.bought_count == 0 }
    end

    context 'calculates standardized_work bought_count when order includes it' do
      Given(:archived_standardized_work) { create :archived_standardized_work, original_work: standardized_work }
      Given(:order) { create :order }
      When do
        order.order_items.create itemable: archived_standardized_work, quantity: 2
        order.send :calculate_bought_count_for_standardized_work
      end
      Then { standardized_work.reload.bought_count == 2 }
    end
  end

  context '#shop_name' do
    Given(:store) { create :store, name: '正宗。商店' }
    Given(:order) { create :order, source: 'shop', channel: store.id }
    Then { order.shop_name == store.name }
  end
end
