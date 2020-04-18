class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    user.karma = 0 if user.karma.nil?

    can :read, Post, status: 'published'
    can :read, Audio do |audio|
      audio.post.published?
    end
    can :read, Article
    can :read, Comment, status: %w[neutral approved flagged]
    can :read, User
    can :comments, User
    can :contributions, User

    if user.persisted?
      can :read, Comment, user_id: user.id
      can :flag, Comment
      can :like, Comment
      can :dislike, Comment

      can :create, Post # Users can contribute with posts with mp3 media

      can :create, Comment if user.karma >= VenganzasDelPasado::Application.config.bad_user_karma_treshold

      if user.karma > VenganzasDelPasado::Application.config.good_user_karma_treshold
        can :publish, Comment, user_id: user.id
      end

      can %i[read approve trash], Comment if %w[moderator editor].include? user.role

      if ['editor'].include? user.role
        can :read, Post
        can :update, Post
      end

      can :manage, :all if user.role == 'admin'

    end
  end
end
