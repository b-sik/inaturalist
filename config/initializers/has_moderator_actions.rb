# frozen_string_literal: true

module HasModeratorActions
  def self.included( base )
    base.extend ClassMethods
  end

  module ClassMethods
    def has_moderator_actions( accepted_actions = nil )
      has_many :moderator_actions, as: :resource
      include HasModeratorActions::InstanceMethods
      return unless accepted_actions

      cattr_accessor :accepted_moderator_actions
      self.accepted_moderator_actions = accepted_actions
    end
  end

  module InstanceMethods
    def hidden?
      moderator_actions.sort_by( &:id ).last.try( :action ) == ModeratorAction::HIDE
    end

    def hideable_by?( hiding_user )
      return false unless hiding_user

      if is_a?( User )
        return false if self == hiding_user
      elsif user
        return false if user == hiding_user
      end
      hiding_user.is_admin? || hiding_user.is_curator?
    end

    def unhideable_by?( unhiding_user )
      return true if hideable_by?( unhiding_user ) && unhiding_user.is_admin?

      false
    end

    def hidden_content_viewable_by?( viewing_user )
      return false unless viewing_user
      return true if hideable_by?( viewing_user )

      if is_a?( User )
        return true if self == viewing_user
      elsif user
        return user == viewing_user
      end

      false
    end
  end
end

ActiveRecord::Base.include HasModeratorActions
