class AddDoorkeeperApplication < ActiveRecord::Migration
  def up
    application_params = {
      name: 'api',
      scopes: 'public',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      uid: SecureRandom.hex(32),
      secret: SecureRandom.hex(32)
    }
    Doorkeeper::Application.seed_once(:name, application_params)
  end

  def down
    Doorkeeper::Application.find_by(name: 'api').try(:destroy)
  end
end
