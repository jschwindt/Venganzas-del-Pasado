class CommentMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def modetation_needed(comment)
    @comment = comment
    mail(:to => 'juan@schwindt.org', :subject => "Comentario para moderar")
  end

end
