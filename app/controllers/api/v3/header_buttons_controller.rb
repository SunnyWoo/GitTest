class Api::V3::HeaderButtonsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  include FeatureFlag

=begin
@api {get} /api/header_button Get Header buttons info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup header_button
@apiName GetheaderButtons
@apiSuccessExample {json} Response-Example:
  {
    "header_buttons": [
      {
        "key": "editor"
        "url": "/zh-TW/works/new",
        "text": "開始印",
        "children": {
          "手機殼": [ { "url": "/zh-TW/works?model_id=1", "text": "Samsung Note 3 手機殼" } ]
        }
      },
      {
        "key": "shop",
        "url": "/zh-TW/shop",
        "text": "設計師商店",
        "children": {
          "保護套": [ { "url": "/zh-TW/works?model_id=14", "text": "iPad Air 2 保護套" } ],
          "手機殼": [
            { "url": "/zh-TW/works?model_id=2", "text": "Samsung S5 手機殼" },
            { "url": "/zh-TW/works?model_id=8", "text": "iPhone 6 Plus 手機殼" }
          ]
        }
      },
      {
        "key": "app",
        "url": "http://bit.ly/1nMC8yU",
        "text": "iOS APP"
      },
      {
        "key": "duncan",
        "url": "/zh-TW/campaign/duncan",
        "text": "Duncan Design"
      }
    ]
  }
=end
  def show
    @links = [
      editor_feature_link,
      build_link('shop', shop_index_path, I18n.t('page.btns.shop'), product_model_children('design')),
      build_link('app', 'http://bit.ly/1nMC8yU', I18n.t('page.btns.app')),
      duncan_feature_link
    ].compact

    render json: @links
  end

  private

  def editor_feature_link
    build_link('editor', new_work_path, I18n.t('page.btns.create'), product_model_children('customize'))
  end

  def duncan_feature_link
    return nil unless feature(:duncan).enable_for_current_session?
    build_link('duncan', campaign_path(:duncan), 'Duncan Design')
  end

  def product_model_children(platform)
    children = {}
    product_models(platform).each do |product_model|
      name = product_model.category.name
      children[name] ||= []
      children[name] << { url: works_path(model_id: product_model.id), text: product_model.name }
    end
    children
  end

  def product_models(platform)
    if 'design' == platform
      ProductModel.includes(:category).where("design_platform->>'website' = ?", 'true')
    else
      ProductModel.includes(:category).where("customize_platform->>'website' = ?", 'true')
    end
  end

  def build_link(key, url, text, children = nil)
    { key: key, url: url, text: text, children: children }
  end
end
