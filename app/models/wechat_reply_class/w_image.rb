module WechatReplyClass
class WImage
	def initialize(hash)
      @message = Message.factory hash
    end
end
end
