# Preview all emails at http://localhost:3000/rails/mailers/post_mailer
class PostMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/post_mailer/new_contribution
  def new_contribution
    PostMailer.with(post: Post.where.not(contributor: nil).first).new_contribution
  end

end
