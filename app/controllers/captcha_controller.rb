class CaptchaController < ApplicationController
  def verify
    render json: { success: simple_captcha_valid? }
  end
end
