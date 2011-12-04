class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    can :read, :all
    
    if user.karma.nil?
      user.karma = 0
    end
    
    if user.karma >= 0
      can :create, Comment
      can [:destroy, :update], Comment, :user_id => user.id
    end
    
    if user.karma > 500
      can :approve, Comment, :user_id => user.id
    end
    
    if ['admin','moderator','editor'].include? user.role
      can [:destroy, :update], Comment
    end
    
    if ['admin', 'editor'].include? user.role
      can :update, Post
    end
    
    if user.role == 'admin'
      can :manage, :all
    end

  end
end
