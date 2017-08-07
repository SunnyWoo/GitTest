require 'rails-env-favicon'

RailsEnvFavicon.setup do |config|
  # If true then favicon will be gray on non production env
  config.make_grayscale = false
  # or if make_grayscale = false then draw badge on favicon with this options:
  config.text_color = '#ffffff'
  config.background_color = '#ff0000'
end
