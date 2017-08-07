require 'spec_helper'

describe WorksController, type: :controller do
  include Devise::TestHelpers

  let(:work) { create(:work, :with_iphone6_model) }
  let(:work2) { create(:work, :with_unavailable_model) }

  before do
    create(:work, :redeem)
    @user = User.new_guest
    @user.save
    @user2 = create(:user)
    @work = create(:work, user: @user)
    create(:product_model, name: 'iPhone 5s/5')
  end

  describe '#new' do
    it 'visitable' do
      get :new, locale: 'zh-TW'
      expect(response.status).to eq(200)
    end
  end

  describe '#create' do
    it 'creates work' do
      product = ProductModel.last
      post :create, locale: 'zh-TW', model_id: product.id
      expect(response.status).to eq(302)
      work = Work.last
      expect(response).to redirect_to(edit_work_path(work))
      expect(work.name).to eq('My Design')
      expect(work.product).to eq(product)
      expect(work.work_type).to eq('is_private')
    end

    it 'raises error if model is not found' do
      post :create, locale: 'zh-TW', model_id: 999
      expect(response.status).to eq(404)
    end

    it 'user agent is Googlebot' do
      request.env['HTTP_USER_AGENT'] = 'Googlebot'
      post :create, locale: 'zh-TW', model_id: ProductModel.last.id
      work = Work.last
      expect(work.created_channel).to eq('web')
      expect(work.created_os_type).to eq('Unknown')
    end

    it 'user agent is Macintosh' do
      request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0)'\
                                       'AppleWebKit/537.36 (KHTML, like Gecko) '\
                                       'Chrome/38.0.2125.111 Safari/537.36'
      post :create, locale: 'zh-TW', model_id: ProductModel.last.id
      work = Work.last
      expect(work.created_channel).to eq('web')
      expect(work.created_os_type).to eq('Macintosh')
    end
  end

  describe '#show' do
    it 'shows work' do
      get :show, locale: 'zh-TW', id: work.id
      expect(response.status).to eq(200)
    end

    it 'raises error if model is not found' do
      get :show, locale: 'zh-TW', id: 'na'
      expect(response.status).to eq(404)
    end

    it '#404, work model unavailable' do
      get :show, locale: 'zh-TW', id: work2.id
      expect(response.status).to eq(404)
    end

    it 'should be redirectd to shop path unless work is_public' do
      work.is_private!
      get :show, locale: 'zh-TW', id: work.id
      expect(response.status).to eq(302)
      expect(response).to redirect_to(shop_index_path)
    end

    it 'should be redirectd to shop path unless work belongs to current_user' do
      sign_in :user, @user
      work.is_private!
      expect(work.user).not_to eq @user
      get :show, locale: 'zh-TW', id: work.id
      expect(response.status).to eq(302)
      expect(response).to redirect_to(shop_index_path)
    end

    it 'render ok if work is private and belongs to current_user' do
      sign_in :user, @user
      work.is_private!
      work.user = @user
      work.save
      get :show, locale: 'zh-TW', id: work.id
      expect(response.status).to eq(200)
    end
  end

  describe '#edit' do
    it 'authenticates user' do
      get :edit, locale: 'zh-TW', id: work.id
      expect(response.status).to eq(302)
    end

    it 'shows editor' do
      sign_in :user, @user
      get :edit, locale: 'zh-TW', id: @work.id
      expect(response.status).to eq(200)
    end

    it 'guest visit editor' do
      sign_in :user, @user2
      get :edit, locale: 'zh-TW', id: @work.id
      expect(response.status).to eq(404)
    end
  end

  describe '#update' do
    it 'authenticates user' do
      patch :update, locale: 'zh-TW', id: work.id, work: {}
      expect(response.status).to eq(302)
    end

    it 'updates work' do
      sign_in :user, @user
      patch :update, locale: 'zh-TW', id: @work.id, work: { name: 'xopowo' }
      expect(response.status).to eq(200)
      @work.reload
      expect(@work.name).to eq('xopowo')
    end

    it 'guest updates work' do
      sign_in :user, @user2
      patch :update, locale: 'zh-TW', id: @work.id, work: { name: 'xopowo' }
      expect(response.status).to eq(404)
    end
  end

  describe '#preview' do
    it 'previews work' do
      sign_in :user, @user
      get :preview, locale: 'zh-TW', work_id: @work.id
      expect(response.status).to eq(200)
    end

    it 'guest visit preview' do
      get :preview, locale: 'zh-TW', work_id: 'na'
      expect(response.status).to eq(404)
    end
  end

  describe '#destroy' do
    it 'delete work when work_id is correct' do
      count = Work.count
      sign_in :user, @user
      delete :destroy, locale: 'zh-TW', id: @work.id
      expect(response.code.to_i).to eq(200)
      expect(Work.count).to eq count - 1
    end

    it 'render 404 when work is not found' do
      sign_in :user, @user
      delete :destroy, locale: 'zh-TW', id: 'WTF'
      expect(response.code.to_i).to eq(404)
    end
  end
end
