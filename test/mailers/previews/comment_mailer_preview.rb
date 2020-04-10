# Preview all emails at http://localhost:3000/rails/mailers/comment_mailer
class CommentMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/comment_mailer/moderation_needed
  def moderation_needed
    CommentMailer.with(comment: Comment.first, subject: 'Test Subject').moderation_needed
  end

end
