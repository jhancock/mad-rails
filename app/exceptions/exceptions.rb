class FlowControlException < StandardError
#  attr_accessor :redirect_to, :message, :success_url, :success_message
  def initialize(options = {})
    @options = options
    super
  end

  def redirect_to
    @options[:redirect_to]
  end

  def message
    @options[:message]
  end

  def success_path
    @options[:success_path]
  end

  def success_message
    @options[:success_message]
  end

end

class Unauthenticated < FlowControlException

end

class Unauthorized < FlowControlException

end

