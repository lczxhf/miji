module WechatReplyClass
class WText
	include ReplyWeixinMessage
	def initialize(hash,appid)
      @weixin_message = Message.factory hash
    end

    def handle
    	case @weixin_message.Content
    	when 'TESTCOMPONENT_MSG_TYPE_TEXT'
    		release_completely
    	else
    		common_handle
    	end
    end


    #全网发布时候的检测
    def release_completely
    end

    def common_handle
    	reply_text_message @weixin_message.Content
    end
end
end
