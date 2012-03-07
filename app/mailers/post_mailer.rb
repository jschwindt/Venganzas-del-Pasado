# encoding: utf-8

class PostMailer < ActionMailer::Base
 default from: Devise.mailer_sender

 def new_contribution(post)
   @post = post
   mail(:to => 'juan@schwindt.org', :subject => "Hay una nueva contribución")
 end

end