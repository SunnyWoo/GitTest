require 'spec_helper'

describe GuestToUserService do
  context 'migrate data' do
    let(:cart_data) do
      {
        order_no: '',
        items: {
          'gid://command-p/Work/3': 1
        },
        payment: 'paypal',
        shipping_info: {
          shipping_way: 'standard'
        },
        billing_info: {},
        currency: 'USD'
      }
    end

    class Cart
      include CartRedis
      attr_reader :user_id
      def initialize(user_id)
        @user_id = user_id
      end
    end

    before do
      @from_user = create(:user, role: :guest)
      @to_user = create(:user)
      @work = create(:work, user: @from_user)
      @order = create(:order, user: @from_user)
      @device = create(:device, user: @from_user)
      @wishlist = create(:wishlist, user: @from_user)
      Cart.new(@from_user.id).redis_set(cart_data)
      @wishlist_item = @wishlist.items.create work: create(:work)
    end

    it 'from user migrate data to user', :vcr do
      expect(@work.user.id).to eq(@from_user.id)
      expect(@order.user_id).to eq(@from_user.id)
      expect(@device.user_id).to eq(@from_user.id)
      expect(@wishlist.user_id).to eq(@from_user.id)
      GuestToUserService.migrate_data(@from_user, @to_user)
      expect(@from_user.reload.die?).to eq true
      expect(@work.reload.user.id).to eq(@to_user.id)
      expect(@order.reload.user_id).to eq(@to_user.id)
      expect(@device.reload.user_id).to eq(@to_user.id)
      expect(@wishlist_item.reload.wishlist_id).to eq(@to_user.wishlist.id)
      expect(Cart.new(@from_user.id).redis_get).to be_nil
      expect(Cart.new(@to_user.id).redis_get).to eq(cart_data)
    end

    it 'wishlist of from is nil', :vcr do
      @other_user = create(:user, role: :guest)
      @wishlist = create(:wishlist, user: @other_user)
      @wishlist_item = @wishlist.items.create work: create(:work)
      expect(@wishlist.user_id).to eq(@other_user.id)
      GuestToUserService.migrate_data(@from_user, @to_user)
      expect(@wishlist_item.reload.wishlist_id).to eq(@other_user.wishlist.id)
    end

    it 'fail to migrate if from_user is not a guest', :vcr do
      @from_user.update role: :normal
      expect(@work.user.id).to eq(@from_user.id)
      expect(@order.user_id).to eq(@from_user.id)
      expect(@device.user_id).to eq(@from_user.id)
      expect(@wishlist.user_id).to eq(@from_user.id)
      GuestToUserService.migrate_data(@from_user, @to_user)
      expect(@from_user.reload.die?).to eq false
      expect(@work.reload.user.id).not_to eq(@to_user.id)
      expect(@order.reload.user_id).not_to eq(@to_user.id)
      expect(@device.reload.user_id).not_to eq(@to_user.id)
      expect(@wishlist.reload.user_id).not_to eq(@to_user.id)
      expect(Cart.new(@from_user.id).redis_get).not_to be_nil
      expect(Cart.new(@to_user.id).redis_get).not_to eq(cart_data)
    end
  end
end
