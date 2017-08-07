require 'rails_helper'

=begin
RSpec.describe Print::FactoriesController, type: :controller do
  Given(:factory) { create :factory }
  Given(:factory_member) { create :factory_member, factory: factory }
  before do
    sign_in factory_member
  end

  context '#index' do
    context 'when current_factory#ftp_gateway is nil' do
      before do
        allow(controller.current_factory).to receive(:ftp_gateway).and_return(nil)
      end

      When { get :index }
      Then { response.status == 200 }
      And { assigns(:factory) == factory }
      # And { expect(controller.current_factory).to receive(:build_ftp_gateway) }
    end

    context 'when current_factory#ftp_gateway is not nil' do
      When { get :index }
      Then { response.status == 200 }
      And { assigns(:factory) == factory }
      And { expect(factory).not_to receive(:build_ftp_gateway) }
    end
  end

  context '#update' do
    context 'update success' do
      Given(:params) do
        { factory: { ftp_gateway_attributes: {} } }
      end

      When { put :update, { id: factory.id }.merge!(params) }
      Then { expect(response).to redirect_to(print_factories_path) }
      And { expect(flash[:notice]).to be_present }
    end

    context 'update fail' do
      Given(:params) do
        { factory: { ftp_gateway_attributes: {} } }
      end
      before do
        allow(controller.current_factory).to receive(:update_attributes).and_return(false)
      end

      When { put :update, { id: factory.id }.merge!(params) }
      Then { flash[:error] == [] }
    end
  end
end
=end
