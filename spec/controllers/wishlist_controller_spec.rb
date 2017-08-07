require 'spec_helper'

RSpec.describe WishlistsController, type: :controller do
  let(:work){ create :work }
  let(:user){ create :user }

  context "#add" do

    context "when a user sign in" do
      before do
        sign_in user
        get :add, locale: 'zh-TW', id: work.id
      end

      it "returns ok with adding a work" do
        expect(response).to be_ok
        expect(JSON.parse(response.body)['message']).to eq('normal')
        expect(user.reload.wishlist).not_to be_nil
        expect(user.wishlist.items.last.work_id).to eq work.id
      end

      it "returns ok with adding the same work more than once" do
        get :add, locale: 'zh-TW', id: work.id
        expect(response).to be_ok
        expect(user.wishlist.works.last).to eq work
        expect(user.reload.wishlist.works.to_a.size).to eq 1 # DISTINCT ON cannot use with COUNT
      end

    end

    it "returns ok when a user does not sign in" do
      get :add, locale: 'zh-TW', id: work.id
      expect(response).to be_ok
      expect(JSON.parse(response.body)['message']).to eq('guest')
    end

  end

  context "#destroy" do
    context "when a user sign in" do
      before do
        user.create_wishlist
        user.wishlist.works << work
        user.save
        sign_in user
        delete :destroy, locale: 'zh-TW', id: work.id
      end

      it "returns ok with destroying the work" do
        expect(response).to be_ok
        expect(user.reload.wishlist.works).not_to include(work.id)
      end

      it 'returns ok with destroying the same work more than once' do
        delete :destroy, locale: 'zh-TW', id: work.id
        expect(response).to be_ok
        expect(user.reload.wishlist.works).not_to include(work.id)
      end

    end

    it "returns ok when a user signs in without a wishlist" do
      user.save
      sign_in user
      delete :destroy, locale: 'zh-TW', id: work.id
      expect(response).to be_ok
    end

    it "returns ok accetpable when a user does not sign in" do
      delete :destroy, locale: 'zh-TW', id: work.id
      expect(response.code.to_i).to eq 200
    end
  end

end
