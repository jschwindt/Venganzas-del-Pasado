class CommentMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def moderation_needed(comment, subject)
    @comment = comment
    mail(:to => 'juan@schwindt.org', :subject => subject)
  end

end
