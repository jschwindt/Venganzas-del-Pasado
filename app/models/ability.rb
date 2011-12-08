class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.karma.nil?
      user.karma = 0
    end

    can :read, Post, :status => 'published'
    can :read, Article, :status => 'published'
    can :read, Comment, :status => 'approved'

    if user.persisted?
      can :read, Comment, :user_id => user.id
      can :flag, Comment
    end

    if user.persisted? && user.karma >= 0
      can :create, Comment
      can [:destroy, :update], Comment, :user_id => user.id
    end

    if user.karma > VenganzasDelPasado::Application.config.good_user_karma_treshold
      can :approve, Comment
    end

    if ['moderator','editor'].include? user.role
      can [:destroy, :update], Comment
    end

    if ['editor'].include? user.role
      can :read, Post
      can :update, Post
    end

    if user.role == 'admin'
      can :manage, :all
    end

  end
end
