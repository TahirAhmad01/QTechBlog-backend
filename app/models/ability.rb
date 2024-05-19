class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      if user.super_admin?
        can :manage, :all
      elsif user.admin?
        cannot [:edit, :destroy, :update], [Category, Tag]
        can :manage, Blog
        can :destroy, Comment
      elsif user.author?
        cannot [:edit, :destroy, :update], [Category, Tag]
        can [:create, :update, :destroy], Blog, user_id: user.id
        can [:update, :create, :destroy], Comment, user_id: user.id
      elsif user.user?
        cannot [:create, :destroy, :update], [Category, Tag, Blog]
        can [:create, :update], Comment, user_id: user.id
      end
    end

    can :read, [Category, Tag, Blog, Comment]
  end
end
