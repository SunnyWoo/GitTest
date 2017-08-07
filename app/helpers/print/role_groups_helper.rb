module Print::RoleGroupsHelper
  def disabled_role(role_group, name)
    role_group.role_names.include?(name) ? 'Enable' : 'Disable'
  end

  def role_group_names(factory_member)
    factory_member.role_groups.map(&:name).join('<br />').html_safe
  end

  def role_group_changed_info(activity)
    changeset = activity.extra_info[:changeset]
    changeset.map do |column, changed|
      next unless column.in?(%w(name roles))
      column_info = RoleGroup.human_attribute_name(column)
      column_data = t('factory_member.info_updated', from: changed[0], to: changed[1])
      "#{column_info}: #{column_data}"
    end.join("\n")
  end
end
