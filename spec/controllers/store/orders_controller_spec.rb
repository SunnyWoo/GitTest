require 'spec_helper'

describe Store::OrdersController, type: :controller do
  # 改很大有空再改
  # before do
  #   CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
  #   CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
  # end

  # let!(:order) { create(:order) }
  # let!(:shop_order) { create(:order, :shop) }
  # let!(:params) { { locale: :en } }

  # describe '#search', type: :controller do
  #   context 'GET' do
  #     it 'returns 302 when format html' do
  #       get :search, params.merge(format: :html)
  #       expect(response).to have_http_status(302)
  #     end

  #     it 'returns 404 when format json without phone and order_no params' do
  #       get :search, params.merge(format: :json)
  #       expect(response).to have_http_status(404)
  #     end

  #     it 'returns 404 when with order' do
  #       get :search, params.merge!(format: :json,
  #                                  phone: order.billing_info_phone,
  #                                  order_no: order.order_no)
  #       expect(response).to have_http_status(404)
  #     end

  #     it 'returns 200 when with shop order' do
  #       get :search, params.merge!(format: :json,
  #                                  phone: shop_order.billing_info_phone,
  #                                  order_no: shop_order.order_no)
  #       expect(response).to have_http_status(200)
  #     end
  #   end

  #   context 'POST' do
  #     it 'returns 302 when format html' do
  #       post :search, params.merge(format: :html)
  #       expect(response).to have_http_status(302)
  #     end

  #     it 'returns 404 when format json without phone and order_no params' do
  #       post :search, params.merge(format: :json)
  #       expect(response).to have_http_status(404)
  #     end

  #     it 'returns 200 when format json' do
  #       post :search, params.merge!(format: :json,
  #                                   phone: shop_order.billing_info_phone,
  #                                   order_no: shop_order.order_no)
  #       expect(response).to have_http_status(200)
  #     end
  #   end
  # end
end
