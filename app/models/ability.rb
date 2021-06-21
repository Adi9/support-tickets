# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_a?(AdminUser)
      can :manage, :all
    else
      can [:read, :create], SupportTicket
      unless user.blank?
        can [:update, :destroy], SupportTicket, { user_id: user.id }
      end
    end
  end
end
