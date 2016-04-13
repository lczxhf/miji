module WechatReplyClass
class WLocation
include ReplyWeixinMessage
	def initialize(hash)
      @message = Message.factory hash
    end

	def handle
	    if @message.ToUserName == 'gh_3c884a361561'
		auto_release
	    end
	end

	def auto_release
		reply_text_message @message.Event+'from_callback'
	end
end
end
