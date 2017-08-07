class CampaignController < ApplicationController
  include WorksSorter
  include Campaigns2015
  include Campaigns2016

  before_action :set_device_type
  before_action :force_zh_tw
  before_action :find_campaign
  before_action :check_campaign_feature_enabled

  layout 'campaign'

  def show
    @app_hash = params.slice :commandp_app
    if @campaign.class.to_s == 'Campaign'
      simple_campaign
    else
      send(@campaign)
    end
  end

  private

  def process_phone_ver_data
    @category_products = {}
    @category_names = {}
    @works.each do |w|
      next unless w.product.available?
      @category_products[w.product_key] ||= []
      @category_products[w.product_key] += Array(w)
      @category_names[w.product_key] = w.product_name
    end
  end

  def process_pc_ver_data
    process_pc_all_categories
    if params[:m] && params[:m] != 'all-cases'
      @model = ProductModel.wildcard_or_find_by(params[:m])
      @works = @works.where(model_id:  @model.id)
    else
      @model = ProductModel.wildcard
    end
    model_ids = @works.present? ? @works.pluck(:model_id).uniq : []
    process_pc_ver_data2
  end

  def process_pc_all_categories
    @work_models = ProductModel.where(id: @works.map(&:model_id).uniq).available.unshift(ProductModel.wildcard)
    @work_categories = {}
    @work_models.each do |model|
      next unless model.try(:category_id)
      @work_categories[model.category_id] ||= { category: model.category, models: [] }
      @work_categories[model.category_id][:models] << model
    end
    @work_categories = @work_categories.sort_by { |_k, v| v[:models].size }.reverse.to_h
    @default_model = ProductModel.find_by(key: 'iphone_6_cases')
    @default_category = @default_model.category
  end

  def process_pc_ver_data2
    @works = sorted_works(params[:sort], @works).page(params[:page]).per_page(30)
    @models = ProductModel.model_list
  end

  def force_zh_tw
    return if params[:locale] == 'zh-TW'
    redirect_to url_for(params.merge(locale: 'zh-TW'))
  end

  def find_campaign
    id = params[:id].downcase.to_sym
    @campaign = Campaigns2015.instance_methods.find { |name| name == id }
    @campaign = Campaigns2016.instance_methods.find { |name| name == id } if @campaign.nil?
    @campaign = Campaign.find_by(key: params[:id]) if @campaign.nil?
    render_404 if @campaign.blank?
  end

  def check_campaign_feature_enabled
    key = @campaign.class.to_s == 'Campaign' ? @campaign.key.to_sym : @campaign
    render_404 unless feature(key).enable_for_current_session? || Rails.env.development?
  end

  def get_ig_images(tag, count = 10, image_size = 'low_resolution')
    call_ig_api("https://api.instagram.com/v1/tags/#{tag}/media/recent", count, image_size)
  end

  # commandptw 官方帳號ig 圖片
  def get_ig_cp_images(count = 10, image_size = 'low_resolution')
    call_ig_api('https://api.instagram.com/v1/users/1967105485/media/recent', count, image_size)
  end

  # image_size: thumbnail(150*150) low_resolution(320*320) standard_resolution(640*640)
  def call_ig_api(url, count = 10, image_size = 'low_resolution')
    images = []
    client_id = '5607761e84f14957963372e68c0409b8'
    begin
      ig = HTTParty.get("#{url}?client_id=#{client_id}&count=#{count}")
      if ig['meta'] && ig['meta']['code'] == 200 && ig['data'].size > 0
        images = ig['data'].map{ |d| d['images'][image_size]['url'] }
      end
    rescue => _e
      nil
    end
    images
  end
end
