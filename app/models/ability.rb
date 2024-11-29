# Implementation class for Cancan gem. Instead of overriding this class, consider adding new permissions
# using the special +register_ability+ method which allows extensions to add their own abilities.
#
# See https://github.com/CanCanCommunity/cancancan for more details.
require "cancan"

class Ability
  include CanCan::Ability

  class_attribute :abilities
  self.abilities = Set.new

  # Allows us to go beyond the standard cancan initialize method which makes it difficult for engines to
  # modify the default +Ability+ of an application.  The +ability+ argument must be a class that includes
  # the +CanCan::Ability+ module.  The registered ability should behave properly as a stand-alone class
  # and therefore should be easy to test in isolation.
  def self.register_ability(ability)
    abilities.add(ability)
  end

  def self.remove_ability(ability)
    abilities.delete(ability)
  end

  def initialize(user)
    alias_cancan_delete_action

    user ||= User.new

    if user.persisted? && user.try(:admin?)
      apply_admin_permissions(user)
    else
      apply_user_permissions(user)
    end

    protect_admin_role
  end

  protected

  def alias_cancan_delete_action
    alias_action :delete, to: :destroy
    alias_action :create, :update, :destroy, to: :modify
  end

  def apply_admin_permissions(user)
    can :manage, :all
  end

  def apply_user_permissions(user)
    can :manage, :all
  end

  def protect_admin_role
    cannot [ :update, :destroy ], Role, name: [ "admin" ]
  end
end
