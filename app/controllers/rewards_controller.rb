class RewardsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %w(validate show)
  skip_before_action :set_locale, only: %w(validate)
  before_action :find_reward, except: %w(share download)

  layout 'rewards'

  def show
    hash = reward_validation_hash(@order_no, @phone)
    if session[:reward_validation].to_a.include?(hash) || @reward.present?
      session[:reward_validation] ||= []
      session[:reward_validation] << hash
      set_meta
      render :show
    elsif params[:id].present?
      redirect_to reward_share_path(id: params[:id])
    else
      redirect_to root_path
    end
  end

  def download
    @reward = Reward.find(params[:reward_id])
    avatar = open(@reward.avatar.url)
    send_data avatar.read, filename: 'avatar.jpg'
  end

  def share
    @reward = Reward.find(params[:id])
    @hash = reward_validation_hash(@reward.order_no, @reward.phone)
    set_meta
  end

  def validate
    response.headers["Access-Control-Allow-Origin"] = "*"
    if @reward.present?
      render json: { success: true, reward: @reward.as_json }, status: :ok
    else
      head :not_found
    end
  end

  protected

  def find_reward
    @order_no, @phone = params.values_at(:order_no, :phone)
    @reward = Reward.find_by(order_no: @order_no, phone: @phone)
  end

  def reward_validation_hash(order_no, phone)
    Digest::MD5.hexdigest(order_no.to_s + phone.to_s)
  end

  def set_meta
    set_meta_tags title: 'Hello I Am 這就是我 #醜臉書',
                  description: '我的臉就是顏值十足的完美藝術傑作，無可取代的個人魅力，這就是我。',
                  og: {
                    title:    'Hello I Am 這就是我 #醜臉書',
                    description: '我的臉就是顏值十足的完美藝術傑作，無可取代的個人魅力，這就是我。',
                    type:     'website',
                    url:      url_for(@reward),
                    image:    @reward.cover.url
                  }
  end

end
