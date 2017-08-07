module MigrateGuestToUserHelper
  extend ActiveSupport::Concern

  def migrate_guest_to_user(old_auth_token, user)
    from_user = AuthToken.find_by!(token: old_auth_token).user
    GuestToUserService.migrate_data(from_user, user) if from_user.present? && user.present?
  end
end
