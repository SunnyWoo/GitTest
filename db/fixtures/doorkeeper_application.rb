return if Rails.env.test?
require 'seed-fu'

application_params = {
  name: 'api',
  scopes: 'public',
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  uid: SecureRandom.hex(32),
  secret: SecureRandom.hex(32)
}
Doorkeeper::Application.seed_once(:name, application_params)
