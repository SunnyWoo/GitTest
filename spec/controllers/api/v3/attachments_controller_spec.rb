require 'spec_helper'

describe Api::V3::AttachmentsController, :freeze_time, :api_v3, type: :controller do
  describe 'POST /attachments', signed_in: false do
    it 'creates attachment and returns it' do
      file = fixture_file_upload('test.jpg')
      post :create, access_token: access_token, file: file
      Attachment.last
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end

    context 'when parameters are not valid' do
      When { post :create, access_token: access_token, remote_file_url: 'data:,' }
      Then { response.status == 422 }
      And { response_json['code'] == 'RecordInvalidError' }
    end
  end

  describe 'GET /attachments/:id', signed_in: false do
    it 'returns current user data' do
      attachment = create(:attachment)
      get :show, id: attachment.aid, access_token: access_token
      expect(response.status).to eq(200)
      expect(response).to render_template(:show)
    end

    context 'returns 404 when not found' do
      When { get :show, id: '{{attachment_aid}}', access_token: access_token }
      Then { response.status == 404 }
    end
  end
end
