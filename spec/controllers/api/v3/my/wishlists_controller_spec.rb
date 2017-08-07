require 'spec_helper'

RSpec.describe Api::V3::My::WishlistsController, :api_v3, type: :controller do
  describe 'GET /my/wishlists' do
    context 'when a user signed in', signed_in: :normal do
      it 'returns the wishlist of a specific user' do
        wishlist = create :wishlist, user: user
        get :show, access_token: access_token
        expect(response.status).to eq 200
        expect(response).to render_template('api/v3/wishlists/show')
        expect(assigns(:wishlist)).to eq(wishlist)
      end
    end

    context 'when a user did not sign in', signed_in: false do
      it 'returns 403 because of a current user required' do
        get :show, access_token: access_token
        expect(response.status).to eq 403
      end
    end

    context 'when user is just a guest', signed_in: :guest do
      it 'returns the wishlist of a guest user' do
        wishlist = create :wishlist, user: user
        get :show, access_token: access_token
        expect(response.status).to eq 200
        expect(response).to render_template('api/v3/wishlists/show')
        expect(assigns(:wishlist)).to eq(wishlist)
      end
    end
  end

  describe 'POST /my/wishlists/:id' do
    context 'when a user signed_in', signed_in: :normal do
      context 'there is no wishlist' do
        Given(:work) { create :work }
        When { post :create, id: work.id, access_token: access_token }
        Then { expect(response.status).to eq 200 }
        And { expect(user.wishlist.works).to include work }
      end

      context 'wishlist already there' do
        before do
          @wishlist = create :wishlist, user: user
          @work = create :work
          post :create, id: @work.id, access_token: access_token
        end

        it 'returns ok with the work added successfully' do
          expect(response.status).to eq 200
          expect(@wishlist.reload.works).to include @work
        end

        it 'should get the one work if the work was added more than once' do
          post :create, id: @work.id, access_token: access_token
          expect(response.status).to eq 200
          expect(@wishlist.reload.works).to include @work
          expect(@wishlist.works.to_a.size).to eq 1
        end
      end
    end

    context 'when a user did not sign in', signed_in: false do
      it 'returns 403 because of a current user required' do
        work = create :work
        post :create, id: work.id, access_token: access_token
        expect(response.status).to eq 403
      end
    end

    context 'when user is just a guest', signed_in: :guest do
      it 'returns ok' do
        wishlist = create :wishlist, user: user
        work = create :work
        post :create, id: work.id, access_token: access_token
        expect(response.status).to eq 200
        expect(wishlist.reload.works).to include work
      end
    end
  end

  describe 'DELETE /my/wishlists/:id' do
    context 'when a user signed_in', signed_in: :normal do
      before do
        @wishlist = create :wishlist, user: user, works: [(create :work, user: user)]
        expect(@wishlist.works.to_a.size).to eq 1
        delete :destroy, id: @wishlist.works.last.id, access_token: access_token
      end

      it 'returns ok with the work successfully deleted' do
        expect(response.status).to eq 200
        expect(@wishlist.reload.works.to_a.size).to eq 0
      end

      it 'returns ok with destroying the same work more than once' do
        delete :destroy, id: @wishlist.works.last.id, access_token: access_token
        expect(response.status).to eq 200
        expect(@wishlist.reload.works.to_a.size).to eq 0
      end
    end

    context 'when a user did not sign in', signed_in: false do
      it 'returns 403 because of a current user required' do
        work = create :work
        delete :destroy, id: work.id, access_token: access_token
        expect(response.status).to eq 403
      end
    end

    context 'when user is just a guest', signed_in: :guest do
      it 'returns ok' do
        wishlist = create :wishlist, user: user
        work = create :work
        wishlist.works << work
        delete :destroy, id: work.id, access_token: access_token
        expect(response.status).to eq 200
        expect(wishlist.reload.works.to_a.size).to eq 0
      end
    end
  end
end
