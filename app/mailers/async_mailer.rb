# Gives an ActionMailer the ability to run any method asynchronously by simply
# prepending an .async call. 
# 
# Example:
#   MyMailer.async.new_user_email(user)

module AsyncMailer
  # Takes care of transforming an ActionMailer method call into a SuckerPunch 
  # perform call.
  # 
  # Example:
  #   MyMailer.new_user_email(user) 
  # becomes
  #   AsyncMailerJob.new.async.perform(MyMailer, :new_user_email, user)

  class AsyncMailerJobRunner
    def initialize(mailer)
      @mailer = mailer
    end

    def method_missing(meth, *args, &block)
      AsyncMailerJob.new.async.perform(@mailer, meth, *args)
    end
  end

  class AsyncMailerJob
    include SuckerPunch::Job

    # Enables us to turn any mailer into an asyncronous one
    def perform(mailer, method, *args)
      Rails.logger.info("Asyncronously running #{mailer.to_s}.#{method.to_s}")
      mailer.send(method, *args).deliver
    end
  end

  module ClassMethods
    def async
      AsyncMailerJobRunner.new(self)
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

end
