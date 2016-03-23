module WechatReplyClass
class WLink
	def initialize(hash)
      @message = Message.factory hash
    end
end
end
