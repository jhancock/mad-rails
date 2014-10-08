class AsyncUserMailerJob
  include SuckerPunch::Job

  def perform(user_id, method, hash = {})
    #Rails.logger.info("Asyncronously running #{mailer.to_s}.#{method.to_s}")
    if hash.empty?
      params = [user_id]
    else
      params = [user_id, hash]
    end
    UserMailer.send(method, *params).deliver
    UserEvents.log user_id, :email, {method: method.to_s, params: hash}
  end
end
