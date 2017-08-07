class Print::FactoryMemberForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :controller, :factory_member
  delegate :valid?, to: :factory_member

  def attributes=(attributes)
    @role_group_ids_was = factory_member.role_group_ids
    @username = factory_member.username
    controller.send(:log_with_print_channel, factory_member)
    factory_member.attributes = attributes
  end

  def save
    return false unless valid?
    @changed = factory_member.changed?
    factory_member.whodunnit(current_factory_member.id) { factory_member.save }
    create_update_activity
  end

  private

  def current_factory_member
    controller.current_factory_member
  end

  def create_update_activity
    changeset = @changed ? factory_member.versions.last.changeset : {}
    if @role_group_ids_was != factory_member.role_group_ids
      groups_were = FactoryRoleGroup.find(@role_group_ids_was).map(&:name)
      groups_are = factory_member.role_groups.pluck(:name)
      changed_group_ids = [groups_were, groups_are]
      changeset['role_groups'] = changed_group_ids
    end
    factory_member.create_activity(:update, changeset: changeset)
  end
end
