worker:        sidekiq -q default -q carrierwave -q print_images -q order_images -q process_images -q mailer -q process_images -c 5
adobe:         sidekiq -q adobe -c 1

# Run Rails & Webpack concurrently
# Example file from webpack-rails gem
rails:         bundle exec rails server --port ${PORT-3000}
webpack:       ./node_modules/.bin/webpack-dev-server --hot --config config/webpack.config.js
