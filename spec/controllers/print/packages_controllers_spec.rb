require 'spec_helper'

describe Print::PackagesController, type: :controller do
  Given(:factory) { create :factory }
  Given(:factory_member) { create :factory_member, factory: factory }
  Given!(:shelf) { create :shelf, factory: factory }

  before { sign_in factory_member }

  context '#create' do
    context 'when params[:package] present' do
      Given(:print_item1) { create :print_item, :with_sublimated }
      Given(:print_item2) { create :print_item, :with_sublimated }
      Given(:params) do
        {
          package: {
            print_items: {}
          }
        }
      end
      before do
        allow(Package).to receive(:create_package_with_print_items).and_return(true)
        allow(controller).to receive(:authorize).with(Package, :create?)
        request.env['HTTP_REFERER'] = print_package_path
      end
      When { post :create, params }
      Then { flash[:notice] == 'success' }
    end

    context 'when params[:package] blank' do
      Given(:print_item1) { create :print_item, :with_sublimated }
      Given(:print_item2) { create :print_item, :with_sublimated }
      Given(:params) do
        {
          package: {}
        }
      end
      before do
        allow(controller).to receive(:authorize).with(Package, :create?)
        request.env['HTTP_REFERER'] = print_package_path
      end
      When { post :create, params }
      Then { flash[:alert] == 'failed' }
    end
  end
end
