require 'spec_helper'

describe ApplicationController, type: :controller do
  let(:user) { create(:user) }

  context 'include module DeviseExtension' do
    context 'check current_user' do
      it 'returns nil when cookie access_token is nil' do
        expect(cookies[:access_token]).to be_nil
        expect(controller.current_user).to be_nil
      end

      it 'returns user when cookie access_token is not nil' do
        expect(controller.current_user).to be_nil
        controller.write_access_token_to_cookie(user)
        expect(cookies[:access_token]).to eq(user.access_token)
        expect(controller.current_user).to eq(user)
      end

      it 'returns user when cookie access_token is not nil' do
        expect(controller.current_user).to be_nil
        cookies[:access_token] = user.access_token
        expect(controller.current_user).to eq(user)
      end

      it 'returns nil when cookie access_token error' do
        expect(controller.current_user).to be_nil
        cookies[:access_token] = 'xxxxx'
        expect(controller.current_user).to be_nil
      end

      context 'when user sign_in' do
        before { sign_in user }

        it 'returs user' do
          expect(controller.current_user).to eq(user)
          expect(cookies[:access_token]).to eq(user.access_token)
        end

        it 'returs nil when after sign_out' do
          sign_out user
          expect(cookies[:access_token]).to be_nil
          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
