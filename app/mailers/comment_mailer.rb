class CommentMailer < ApplicationMailer
  def moderation_needed
    @comment = params[:comment]
    mail(to: 'juan@schwindt.org', subject: params[:subject])
  end
end
