require 'spec_helper'

describe Api::V3::My::LayersController, :api_v3, type: :controller do
  describe '#update' do
    context 'when a user signs in', signed_in: :normal do
      Given!(:work) { create :work, user: user }
      Given(:image_aid) { create(:attachment).aid }
      Given(:filtered_image_aid) { create(:attachment).aid }
      context 'creates layer if uuid is nonexistent' do
        Given!(:layer_count) { work.layers.count }
        When do
          put :update, access_token: access_token,
                       work_uuid:    work.uuid,
                       uuid:         SecureRandom.uuid,
                       position:     3,
                       layer_type:   'photo',
                       image_aid: image_aid,
                       filtered_image_aid: filtered_image_aid
        end
        Then { response.status == 200 }
        And { work.layers(true).count == layer_count + 1 }
        And { expect(response).to render_template(:show) }
        Given(:layer) { work.reload.layers.last }
        And { layer.attached_image_id.nil? }
        And { layer.image.present? }
        And { layer.attached_filtered_image_id.nil? }
        And { layer.filtered_image.present? }
      end

      context 'when feature flag on, creates layer with attachment image aid' do
        Given(:feature_flag_on) { double(FeatureFlag::Feature, enable_for_current_session?: true) }
        Given!(:layer_count) { work.layers.count }
        When { expect(controller).to receive(:feature).with(:api_v3_my_layer_enable_attachment_aid).and_return(feature_flag_on) }
        When do
          put :update, access_token: access_token,
                       work_uuid:    work.uuid,
                       uuid:         SecureRandom.uuid,
                       position:     3,
                       layer_type:   'photo',
                       image_aid: image_aid,
                       filtered_image_aid: filtered_image_aid
        end
        Then { response.status == 200 }
        And { work.layers(true).count == layer_count + 1 }
        And { expect(response).to render_template(:show) }
        Given(:layer) { work.reload.layers.last }
        And { layer.attached_image_id.present? }
        And { layer.image.present? }
        And { layer.attached_filtered_image_id.present? }
        And { layer.filtered_image.present? }
      end

      context 'updates layer if uuid is existent and the layer is mask' do
        Given!(:layer) { create :layer, work: work, mask_id: 1, layer_type: :mask }
        Given!(:layer_count) { work.layers(true).count }
        When do
          put :update, access_token: access_token,
                       work_uuid:    work.uuid,
                       uuid:         layer.uuid,
                       position:     -2,
                       mask_id:      2
        end
        Then { response.status == 200 }
        And { work.layers(true).count == layer_count }
        And { layer.reload.position == -2 }
        And { layer.reload.mask_id == 1 }
        And { expect(response).to render_template(:show) }
      end

      context 'updates layer if uuid is existent and the layer is not masked' do
        Given!(:layer) { create :layer, work: work }
        Given!(:layer_count) { work.layers(true).count }
        When do
          put :update, access_token: access_token,
                       work_uuid:    work.uuid,
                       uuid:         layer.uuid,
                       position:     -2,
                       mask_id:      1
        end
        Then { response.status == 200 }
        And { work.layers(true).count == layer_count }
        And { layer.reload.position == -2 }
        And { layer.reload.mask_id == 1 }
        And { expect(response).to render_template(:show) }
      end

      context 'returns 404 if work_uuid is wrong' do
        When do
          put :update, access_token: access_token,
                       work_uuid:    'I am fake',
                       uuid:         SecureRandom.uuid
        end
        Then { response.status == 404 }
      end
    end

    context 'when user does not sign in', signed_in: false do
      context 'returns 403' do
        Given(:work) { create :work }
        Given(:layer) { create :layer, work: work }
        When do
          put :update, access_token: access_token,
                       work_uuid:    work.uuid,
                       uuid:         layer.uuid,
                       position:     -2
        end
        Then { response.status == 403 }
      end
    end
  end

  describe '#destroy' do
    context 'when a user signs in', signed_in: :normal do
      Given!(:work) { create :work, user: user }
      context 'returns 200 when layer uuid is correct' do
        Given!(:layer) { create :layer, work: work }
        Given!(:layer_count) { work.layers(true).count }
        When do
          delete :destroy, access_token: access_token,
                           work_uuid:    work.uuid,
                           uuid:         layer.uuid
        end
        Then { response.status == 200 }
        And { work.layers(true).count == layer_count - 1 }
        And { expect(response).to render_template(:show) }
      end

      context 'returns 404 when layer uuid is incorrect' do
        Given!(:layer_count) { work.layers(true).count }
        When do
          delete :destroy, access_token: access_token,
                           work_uuid:    work.uuid,
                           uuid:         SecureRandom.uuid
        end
        Then { response.status == 404 }
        And { work.layers(true).count == layer_count }
      end

      context 'returns 404 when work uuid is incorrect' do
        When do
          delete :destroy, access_token: access_token,
                           work_uuid:    SecureRandom.uuid,
                           uuid:         SecureRandom.uuid
        end
        Then { response.status == 404 }
      end
    end

    context 'returns 403 when the user does not sign in', signed_in: false do
      When do
        delete :destroy, access_token: access_token,
                         work_uuid:    SecureRandom.uuid,
                         uuid:         SecureRandom.uuid
      end
      Then { response.status == 403 }
    end
  end
end
