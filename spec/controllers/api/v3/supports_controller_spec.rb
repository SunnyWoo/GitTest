require 'spec_helper'

describe Api::V3::SupportsController, :api_v3, type: :controller do
  describe 'GET /api/supports', signed_in: false do
    context 'list support categories' do
      it 'when locale is default' do
        get :index, access_token: access_token
        expect(response.status).to eq(200)
        expect(response.body).to eq({
          support: {
            categories: I18n.t('support.categories').map { |k, v| [v, k] }
          }
        }.to_json)
      end

      it 'when locale is zh-TW' do
        I18n.locale = 'zh-TW'
        get :index, { access_token: access_token }.merge(HTTP_ACCEPT_LANGUAGE: 'zh-TW')
        expect(response.status).to eq(200)
        expect(response.body).to eq({
          support: {
            categories: I18n.t('support.categories').map { |k, v| [v, k] }
          }
        }.to_json)
      end
    end
  end

  describe 'POST /api/supports' do
    context 'user did not sign in', signed_in: false do
      it 'returns success', :vcr do
        support_params = {
          email: Faker::Internet.email,
          category: 'product',
          subject: 'Support test',
          description: 'Support test',
          attachments: nil
        }
        post :create, { access_token: access_token }.merge(support_params)
        expect(response.status).to eq(201)
        expect(response.body).to eq({ status: 'success' }.to_json)
      end

      it 'reurn error, when subject is nil' do
        support_params = {
          email: Faker::Internet.email,
          category: 'product',
          subject: nil,
          description: 'Support test',
          attachments: nil
        }
        post :create, { access_token: access_token }.merge(support_params)
        expect(response.status).to eq(422)
        expect(response_json['code']).to eq('RecordInvalidError')
      end
    end

    context 'user is sign in', signed_in: :normal do
      it 'returns success', :vcr do
        attachment = create :attachment
        allow_any_instance_of(Attachment).to receive_message_chain('file.url') do
          'http://www.cinemablend.com/images/news_img/35626/Yoda_35626.jpg'
        end
        support_params = {
          email: Faker::Internet.email,
          category: 'product',
          subject: 'Support test',
          description: 'Support test',
          attachments: nil,
          attachment_ids: %W(#{attachment.aid})
        }
        post :create, { access_token: access_token }.merge(support_params)
        expect(response.status).to eq(201)
        expect(response.body).to eq({ status: 'success' }.to_json)
        expect(Pathname.new('tmp/attachments').children.size).to eq 0
      end

      it 'returns error, when email is nil' do
        support_params = {
          category: 'product',
          subject: 'test subject',
          description: 'Support test',
          attachments: nil
        }
        post :create, { access_token: access_token }.merge(support_params)
        expect(response.status).to eq(422)
        expect(response_json['code']).to eq('RecordInvalidError')
      end

      it 'returns 404 with incorrect attachment_ids' do
        support_params = {
          email: Faker::Internet.email,
          category: 'product',
          subject: 'test subject',
          description: 'Support test',
          attachment_ids: %w(WTF)
        }
        post :create, { access_token: access_token }.merge(support_params)
        expect(response.status).to eq(404)
      end
    end
  end
end
