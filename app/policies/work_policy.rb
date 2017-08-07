class WorkPolicy < ApplicationPolicy
  def update?
    (!model.archived?) && (model.user == user) && (model.created_channel == 'web')
  end

  def destroy?
    update?
  end
end
