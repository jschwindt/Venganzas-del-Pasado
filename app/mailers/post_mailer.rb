class PostMailer < ApplicationMailer
  def new_contribution
    @post = params[:post]
    mail(to: 'juan@schwindt.org', subject: 'Hay una nueva contribución')
  end
end
