class AsyncUserMailerJob
  include SuckerPunch::Job

  def perform(user_id, method, hash = {})
    #SuckerPunch.logger.info("This is how you log with SuckerPunch")
    if hash.empty?
      params = [user_id]
    else
      params = [user_id, hash]
    end
    mail = UserMailer.send(method, *params)
    mail['mandrill_tag'] = method.to_s
    mail.deliver
    UserEvents.log user_id, :email, {method: method.to_s, params: hash}
  end
end
