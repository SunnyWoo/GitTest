require 'spec_helper'

describe Admin::TranslationsController, :type => :request do
  before do
    login_admin
  end

  it '#update' do
    put "/admin/translations/test%7cteddybeargg.json", translator: { value: 'It is a toy!'}
    expect(response_json['value']).to eq 'It is a toy!'
  end

end
