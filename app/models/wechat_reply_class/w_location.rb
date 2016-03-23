module WechatReplyClass
class WLocation
	def initialize(hash)
      @message = Message.factory hash
    end
end
end
