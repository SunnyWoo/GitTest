require 'spec_helper'

describe Api::V3::RegistrationsController, :api_v3, type: :controller do
  context '#create' do
    context 'without current_user', signed_in: false do
      context 'register by email creates user and returns success when all params is provided and valid' do
        Given(:data) do
          {
            login:                 'man.utd@commandp.com',
            password:              'Commandp123',
            password_confirmation: 'Commandp123',
            access_token: access_token
          }
        end
        Given!(:user_count) { User.count }
        When { post :create, data }
        Then { response.status == 200 }
        And { User.count == user_count + 1 }
        And { User.last.email == data[:login] }
        And { User.last.activities.last.key == 'sign_up' }
        And { expect(response).to render_template('api/v3/profiles/show') }
      end

      context 'creates user and returns 422 when params missing' do
        Given(:data) do
          {
            login:        'man.utd@commandp.com',
            password:     'Commandp123',
            access_token: access_token
          }
        end
        When { post :create, data }
        Then { response.status == 422 }
      end

      context 'When register_method is mobile' do
        Given(:data) do
          {
            login:                 '18626058997',
            password:              'Commandp123',
            password_confirmation: 'Commandp123',
            access_token: access_token
          }
        end

        # XXX: Hack from 2016-03-08 如果有 code 要檢驗，沒 code 要放過
        context 'return ok' do
          Given!(:user_count) { User.count }
          When { post :create, data }
          Then { response.status == 200 }
          And { User.count == user_count + 1 }
          And { User.last.mobile == data[:login] }
        end

        context 'verify false when parameter code is provided and fail the verification' do
          before { data.merge! code: 'failed' }
          before { expect_any_instance_of(MobileVerifyService).to receive(:verify).and_return(false) }
          When { post :create, data }
          Then { response.status == 401 }
          And { response_json['code'] == 'MobileVerificationFailedError' }
        end

        context 'return ok when parameter code is provided and pass the verification' do
          before { data.merge! code: 'success' }
          before { expect_any_instance_of(MobileVerifyService).to receive(:verify).and_return(true) }
          Given!(:user_count) { User.count }
          When { post :create, data }
          Then { response.status == 200 }
          And { User.count == user_count + 1 }
          And { User.last.mobile == data[:login] }
        end
      end
    end
  end
end
