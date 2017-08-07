module Print::UserRolesHelper
  def factory_member_changed_info(activity)
    changeset = activity.extra_info[:changeset]
    changeset.map do |column, changed|
      column_info = FactoryMember.human_attribute_name(column)
      if column == 'role_groups'
        column_data = t('factory_member.info_updated', from: changed[0], to: changed[1])
      elsif column == 'encrypted_password'
        column_data = t('factory_member.encrypted_password_updated')
      elsif column == 'enabled'
        from = changed[0] ? t('factory_member.enabled') : t('factory_member.disabled')
        to = changed[1] ? t('factory_member.enabled') : t('factory_member.disabled')
        column_data = t('factory_member.info_updated', from: from, to: to)
      elsif column == 'username'
        column_data = t('factory_member.info_updated', from: changed[0], to: changed[1])
      end
      "#{column_info}: #{column_data}"
    end.join("\n")
  end
end
