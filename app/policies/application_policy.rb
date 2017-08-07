class ApplicationPolicy
  attr_reader :context, :model

  def initialize(context, model)
    @context = context
    @model = model
  end

  def index?
    false
  end

  def show?
    scope.where(id: model.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(context, model.class)
  end

  delegate :user, :country_code, to: :context, allow_nil: true

  class Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @scope = scope
    end

    def resolve
      scope
    end

    delegate :user, :country_code, to: :context, allow_nil: true
  end
end

