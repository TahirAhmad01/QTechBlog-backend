class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?  # Check if the user is logged in
      if user.super_admin?
        can :manage, :all
      elsif user.admin?
        cannot [:edit, :destroy, :update], [Category, Tag]
        can :manage, Blog
      elsif user.author?
        can [:create, :update, :destroy], Blog, user_id: user.id
        can [:update, :create, :destroy], Comment, user_id: user.id
      else
        can [:create, :update], Comment, user_id: user.id
      end
    end

    can :read, [Category, Tag, Blog, Comment]  # Allow all users to read these resources
  end
end
