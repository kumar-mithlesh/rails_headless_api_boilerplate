# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record, :abilities, :current_account

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, I18n.t(:not_implemented_error, scope: :pundit, resource: self.class)
    end

    private

    attr_reader :user, :scope
  end

  def initialize(user, record)
    raise Pundit::NotAuthorizedError unless user

    @user = user
    @record = record
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
