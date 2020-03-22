class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.karma.nil?
      user.karma = 0
    end

    can :read, Post, :status => 'published'
    can :read, Audio do |audio|
      audio.post.published?
    end
    can :read, Article
    can :read, Comment, :status => ['neutral', 'approved', 'flagged']
    can :opinions, Comment, :status => ['neutral', 'approved', 'flagged']
    can :read, User
    can :comments, User
    can :contributions, User
    can :likes, User
    can :dislikes, User

    if user.persisted?
      can :read, Comment, :user_id => user.id
      can :flag, Comment
      can :like, Comment
      can :dislike, Comment

      can :create, Post   # Users can contribute with posts with mp3 media

      if user.karma >= VenganzasDelPasado::Application.config.bad_user_karma_treshold
        can :create, Comment
      end

      if user.karma > VenganzasDelPasado::Application.config.good_user_karma_treshold
        can :publish, Comment, :user_id => user.id
      end

      if ['moderator','editor'].include? user.role
        can [:read, :approve, :trash], Comment
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
end
