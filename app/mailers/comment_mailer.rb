class CommentMailer < ActionMailer::Base
  def moderation_needed(comment, subject)
    @comment = comment
    mail(to: 'juan@schwindt.org', subject: subject)
  end
end
