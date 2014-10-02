class AsyncMailerJob
  include SuckerPunch::Job

  def perform(mailer, method, *args)
    #Rails.logger.info("Asyncronously running #{mailer.to_s}.#{method.to_s}")
    mailer.send(method, *args).deliver
    EventLog.log :email, {mailer: mailer.to_s, method: method.to_s, args: args}
  end
end
