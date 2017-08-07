require 'spec_helper'

describe Api::V3::My::Works::BatchesController, :api_v3, type: :controller do
  Given(:product_model) { create(:product_model) }
  Given(:image_aid) { create(:attachment).aid }
  Given(:filtered_image_aid) { create(:attachment).aid }
  Given(:uuid) { SecureRandom.uuid }
  Given(:cover_image_aid) { create(:attachment).aid }
  context '#update' do
    context 'user signed in', signed_in: :normal do
      context 'create work if uuid not found' do
        Given(:layers_attributes) do
          [
            {
              layer_type:         'photo',
              uuid:               SecureRandom.uuid,
              position:           3,
              layer_type:         'photo',
              image_aid:          image_aid,
              filtered_image_aid: filtered_image_aid
            }
          ]
        end

        context 'create unfinished work without params finish' do
          When do
            put :update, uuid: uuid, access_token: access_token,
                         name: 'hello', model_id: product_model.id,
                         cover_image_aid: cover_image_aid,
                         layers_attributes: layers_attributes
          end
          Given(:work) { Work.last }
          Given(:layer) { work.layers.first }
          Then { expect(response).to render_template(:show) }
          And { work.name == 'hello' }
          And { work.product == product_model }
          And { work.user == user }
          And { work.application == controller.current_application }
          And { work.attached_cover_image_id.nil? }
          And { work.cover_image.present? }
          And { !work.finished? }
          And { layer.image.present? }
          And { layer.filtered_image.present? }
          And { layer.position == 3 }
          And { layer.photo? }
        end

        context 'create finished work with params finish' do
          When do
            put :update, uuid: uuid, access_token: access_token,
                         name: 'hello', model_id: product_model.id,
                         cover_image_aid: cover_image_aid,
                         layers_attributes: [],
                         finish: true
          end
          Given(:work) { Work.last }
          Then { expect(response).to render_template(:show) }
          And { work.finished? }
        end
      end

      context 'update work if uuid found' do
        Given(:layer) { create :layer }
        Given(:work) { layer.work }
        Given(:layers_attributes) do
          [
            {
              id:         layer.id,
              position:   87,
              layer_type: 'text',
              font_text:  '87分不能再高了!'
            },
            {
              layer_type:         'photo',
              uuid:               SecureRandom.uuid,
              position:           99,
              layer_type:         'photo',
              image_aid:          image_aid,
              filtered_image_aid: filtered_image_aid
            }
          ]
        end
        before { work.update user: user }
        When do
          patch :update, uuid: work.uuid, access_token: access_token,
                         name: 'Hello World', model_id: product_model.id,
                         layers_attributes: layers_attributes,
                         finish: true
        end
        Then { expect(response).to render_template(:show) }
        And { work.reload.name == 'Hello World' }
        And { work.product == product_model }
        And { work.finished? }
        And { layer.reload.position == 87 }
        And { layer.text? }
        And { layer.font_text == '87分不能再高了!' }
        And { work.layers.photo.first.position == 99 }
      end
    end

    context 'user does not signed in', signed_in: false do
      When do
        put :update, uuid: uuid, access_token: access_token,
                     name: 'hello', model_id: product_model.id,
                     cover_image_aid: cover_image_aid,
                     layers_attributes: []
      end
      Then { response.status == 403 }
    end
  end
end
