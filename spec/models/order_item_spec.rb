# == Schema Information
#
# Table name: order_items
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  itemable_id      :integer
#  itemable_type    :string(255)
#  quantity         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  timestamp_no     :integer
#  print_at         :datetime
#  aasm_state       :string(255)
#  pdf              :string(255)
#  prices           :json
#  original_prices  :json
#  discount         :decimal(8, 2)
#  remote_id        :integer
#  delivered        :boolean          default(FALSE)
#  deliver_complete :boolean          default(FALSE)
#  remote_info      :json
#  selling_prices   :json
#

require 'spec_helper'

describe OrderItem do
  it 'FactoryGirl' do
    expect(build(:order_item)).to be_valid
  end

  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:itemable) }
  it { should have_many(:adjustments) }

  describe '#quantity' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  context 'paper_trail' do
    it 'version check' do
      with_versioning do
        order_item = create :order_item
        first_version_size = order_item.versions.size
        expect(first_version_size).not_to eq 0
        order_item.update_attribute(:quantity, 99)
        expect(order_item.versions.size).to be > first_version_size
      end
    end
  end

  describe 'before create' do
    before { create_basic_currencies }

    it 'stores product model prices' do
      order_item = create(:order_item)
      expect(order_item.prices).to eq(order_item.itemable.product.prices)
    end

    it 'stores special price for work' do
      tier = { 'tier' => 1, TWD: 10, HKD: 1, JPY: 30 }
      price_tier = PriceTier.create(data: tier)
      work = create(:work, price_tier: price_tier)
      order_item = create(:order_item, itemable: work)
      expect(order_item.prices).to eq(price_tier.prices)
    end
  end

  context 'after create' do
    it 'enqued create archived work job' do
      expect(CreateArchiveItemWorker).to receive(:perform_async)
      order_item = create(:order_item)
      order_item.run_callbacks(:commit)
    end
  end

  it 'does not change price after model price updated' do
    order_item = create(:order_item)
    tier = { 'tier' => 1, TWD: 10, HKD: 1, JPY: 30 }
    price_tier = PriceTier.create(data: tier)
    order_item.itemable.product.update(price_tier: price_tier)
    order_item.save
    expect(order_item.prices).not_to eq(price_tier.prices)
  end

  context '#print_image_exist?' do
    context 'print image is exist' do
      Given(:order_item) { create :order_item }
      Given(:print_image_file) { "#{Rails.root}/db/fixtures/images/watermelon.jpg" }
      Given(:print_image) do
        ActionDispatch::Http::UploadedFile.new(
          filename: File.basename(print_image_file), tempfile: File.open(print_image_file)
        )
      end
      When { order_item.itemable.update(print_image: print_image) }
      Then { order_item.print_image_exist? == true }
    end

    context 'print image is not exist' do
      Given(:order_item) { create :order_item }
      Then { order_item.print_image_exist? == false }
    end
  end

  it '#china_archive_attributes' do
    order_item = create(:order_item)
    attributes = { item_id: order_item.id,
                   quantity: order_item.quantity,
                   itemable_type: order_item.itemable_type,
                   work: order_item.itemable.china_archive_attributes }
    expect(order_item.china_archive_attributes).to eq(attributes)
  end

  context '#clone_to_print_items' do
    context 'when need_deliver?' do
      Given(:order_item) { create :order_item }
      before { order_item.itemable.product.update(remote_key: 'key') }
      When { order_item.clone_to_print_items }
      Then { order_item.print_items.size == order_item.quantity }
      And { order_item.print_items.pluck(:aasm_state).uniq == ['delivering'] }
    end

    context 'when not need_deliver?' do
      context 'when need_deliver?' do
        Given(:order_item) { create :order_item }
        When { order_item.clone_to_print_items }
        Then { order_item.print_items.pluck(:aasm_state).uniq == ['pending'] }
      end
    end
  end

  context 'need_deliver?' do
    Given(:product) { create :product_model, remote_key: 'key' }
    Given(:work) { create :work, product: product }
    Given(:order_item) { create :order_item, itemable: work }
    Then { order_item.need_deliver? == true }
  end

  context 'aasm' do
    context '#deliver' do
      Given(:order_item) { create :order_item }
      When { order_item.deliver!  }
      Then { order_item.aasm_state == 'delivering' }
    end

    context '#receive' do
      Given(:order) { create :order, delivered_at: Time.zone.now }
      before { order.order_items.delete_all }
      Given(:order_item) { create :order_item, order: order }
      When { order_item.deliver!  }
      When { order_item.receive!  }
      Then { order_item.aasm_state == 'received' }
    end

    context 'reprint' do
      context 'when order_item need deliver' do
        Given(:order) { create :order }
        When { order.order_items.update_all(aasm_state: 'onboard') }
        Given(:order_item) { create :order_item, order: order }
        before do
          order_item.update(aasm_state: 'onboard')
          allow(order_item).to receive(:need_deliver?).and_return(true)
        end
        Then { expect { order_item.reprint! }.to raise_error(AASM::InvalidTransition) }
      end

      context 'when order_item need not deliver' do
        Given(:order) { create :order }
        When { order.order_items.update_all(aasm_state: 'onboard') }
        Given(:order_item) { create :order_item, order: order }
        before do
          order.update!(aasm_state: 'packaged')
          order_item.update(aasm_state: 'onboard')
          allow(order_item).to receive(:need_deliver?).and_return(false)
        end
        When { order_item.reprint! }
        Then { order.order_items.pluck(:aasm_state).uniq == ['pending'] }
        And { order.paid? }
        And { order.ongoing? }
      end
    end

    context '#toboard' do
      Given(:order_item) { create :order_item, aasm_state: 'qualified' }
      Given(:package) { create :package }
      Given!(:print_item) { create :print_item, order_item: order_item, aasm_state: 'qualified', package: package }

      When { order_item.toboard! }
      Then { order_item.reload.onboard? }
      And { order_item.activities.last.key == 'toboard' }
    end

    context '#ship' do
      Given(:order_item) { create :order_item, aasm_state: 'onboard' }
      Given(:package) { create :package }
      Given!(:print_item) { create :print_item, order_item: order_item, aasm_state: 'onboard', package: package }

      context 'when ship form onboard' do
        When { order_item.ship! }
        Then { order_item.reload.shipping? }
        And { order_item.activities.last.key == 'ship' }
      end

      context 'when ship form pending' do
        Given(:order_item) { create :order_item }
        Then { expect { order_item.ship! }.to raise_error(AASM::InvalidTransition) }
      end
    end
  end

  context '#check' do
    context 'transitions form sublimated to qualified' do
      Given!(:order_item) { create :order_item, aasm_state: 'sublimated' }
      When { order_item.check! }
      Then { order_item.reload.qualified? }
    end
  end

  context 'scope#unpackaged' do
    Given(:unpackaged_order_item) { create :order_item }
    Given!(:print_item1) { create :print_item, order_item: unpackaged_order_item, package_id: nil }
    Given!(:print_item2) { create :print_item, order_item: unpackaged_order_item, package_id: nil }
    Given(:packaged_order_item) { create :order_item }
    Given!(:print_item3) { create :print_item, order_item: packaged_order_item, package_id: 1 }

    Given(:unpackaged_order_items) { OrderItem.unpackaged }
    Then { unpackaged_order_items.pluck(:id) == [unpackaged_order_item.id] }
  end

  context '#adjusted_price_in_currency' do
    Given(:order) { create(:order).reload }
    Given(:order_item) { order.order_items.first }
    Given(:currency) { order_item.order.currency }
    Given(:promotion) { create :promotion_for_itemable_price }
    Given { order_item.adjustments.build(value: -40, quantity: order_item.quantity, source: promotion) }
    When(:value) { order_item.adjusted_price_in_currency(currency) }
    Then { expect(value.round(2)).to eq(59.9.round(2)) }
  end

  context '#adjustments_value' do
    Given(:order) { create :order }
    Given(:order_item) { create :order_item, order: order }
    Given(:promotion) { create :standardized_work_promotion }
    Given(:promotion2) { create :standardized_work_promotion }
    When do
      quantity = order_item.quantity
      order_item.adjustments.create source: promotion, value: -10, event: 'apply', quantity: quantity
      order_item.adjustments.create source: promotion, value: 10, event: 'fallback', quantity: quantity
      order_item.adjustments.create source: promotion2, value: -15, event: 'apply', quantity: quantity
    end
    Then { order_item.adjustments_value == (-10 + 10 + -15) }
  end

  context '#apply_with_available_promotion' do
    before do
      @promotion = create :'promotion/for_standardized_work', aasm_state: :started
      @standardized_work = create :standardized_work, :with_iphone6_model
      create :promotion_reference, promotion: @promotion, promotable: @standardized_work, price_tier: create(:price_tier)
      @order = build :order
    end
    context 'when available' do
      before do
        Timecop.freeze 3.days.from_now
        create_basic_currencies
      end
      context 'with applicable promotion' do
        Given(:order_item) { build :order_item, itemable: @standardized_work, order: @order }
        When { order_item.apply_with_available_promotion }
        Then { order_item.adjustments.last.apply? }
      end

      context 'with unapplicable promotion' do
        Given(:work) { create :work, :is_public }
        Given(:order_item) { build :order_item, itemable: work, order: @order }
        When { order_item.apply_with_available_promotion }
        Then { order_item.adjustments.blank? }
      end
      after { Timecop.return }
    end

    context 'with unavailable and applicable promotion' do
      Given(:order_item) { build :order_item, itemable: @standardized_work, order: @order }
      When { order_item.apply_with_available_promotion }
      Then { order_item.adjustments.blank? }
    end
  end

  context '#adjustments_value' do
    Given(:order) { create :order }
    Given(:order_item) { create :order_item, order: order }
    Given(:promotion) { create :standardized_work_promotion }
    Given(:promotion2) { create :standardized_work_promotion }
    When do
      order_item.adjustments.create value: -30, order: order, source: promotion, event: 'apply'
      order_item.adjustments.create value: -40, order: order, source: promotion2, event: 'apply'
    end
    Then { order_item.adjustments_value == -70 }
  end

  context '#per_itemable_price' do
    Given(:order) { create :order, currency: 'USD' }
    Given(:order_item) { create :order_item, quantity: 3, order: order }
    When { order_item.prices['USD'] == 99.9 }
    Then { order_item.per_itemable_price == 99.9 }
    And { order_item.per_itemable_price('TWD') == 99.9 * 30 }
  end

  describe '#selling_price' do
    context 'with non-persisted item, pull value from itemable' do
      Given(:work) { create(:work) }
      Given(:order) { create :order, currency: 'TWD' }
      Given(:order_item) { build :order_item, order: order, itemable: work }
      Given { work.stub(:promotion_special_price).and_return(Price.new(123.0, 'TWD')) }
      Then { expect(order_item.selling_price).to eq Price.new(123.0, 'TWD') }
    end

    context 'with persited item, get value from #selling_prices attribute' do
      Given(:order) { create :order, currency: 'TWD' }
      Given(:work) { create(:work) }
      Given(:order_item) { create :order_item, order: order, itemable: work }
      Given { order_item.stub(:selling_prices).and_return('TWD' => 1999.0, 'USD' => 66.6) }
      When(:selling_price) { order_item.selling_price }
      Then { expect(selling_price).to eq Price.new(1999.0, 'TWD') }
    end
  end

  context '#itemable_name' do
    Given(:order) { create :order, currency: 'TWD' }
    Given(:order_item) { build :order_item, order: order, itemable: work }
    context 'Work, ArchivedWork for Customization' do
      Given(:work) { [create(:work), create(:archived_work)].sample }
      Then { order_item.itemable_name == 'Customization' }
    end

    context 'StandardizedWork, ArchivedStandardizedWork for Designer' do
      Given(:work) { [create(:standardized_work), create(:archived_standardized_work)].sample }
      Then { order_item.itemable_name == 'Designer' }
    end
  end
end
