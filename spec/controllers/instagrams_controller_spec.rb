require 'spec_helper'

describe InstagramsController, type: :controller do
  context '#show' do
    context 'renders data if existed' do
      before { allow_any_instance_of(InstagramsController).to receive(:fetch_instagram_data).and_return(urls) }
      Given(:urls) { %w(url_a url_b url_c) }
      When { get :show }
      Then { response.status == 200 }
      And { JSON.parse(response.body)['urls'] == urls }
    end

    context 'returns 404 if inexisted' do
      before { allow_any_instance_of(InstagramsController).to receive(:fetch_instagram_data).and_return(false) }
      When { get :show }
      Then { response.status == 404 }
    end
  end
end
