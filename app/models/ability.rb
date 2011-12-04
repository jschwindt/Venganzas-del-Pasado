class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    can :read, :all
    
    if user.karma.nil?
      user.karma = 0
    end
    
    if user.karma > 0
      can :create, Comment
      can [:edit, :delete, :update], Comment, :user_id => user.id
    end
    
    if user.karma > 100
      can :approve, Comment, :user_id => user.id
    end
    
    if user.karma > 200
      can :approve, Comment
    end
    
    if user.karma > 300
      can [:edit, :delete, :update], Comment
    end
    
    if user.karma > 400
      can :create, Post
      can [:edit, :delete, :update], Post
    end
    
    if user.karma > 9000
      can :manage, :all
    end

  end
end
