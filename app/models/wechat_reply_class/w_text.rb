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
	puts '123'
	reply_text_message "TESTCOMPONENT_MSG_TYPE_TEXT_callback"
    end

    def common_handle
	if @weixin_message.ToUserName == 'gh_3c884a361561'
		if @weixin_message.Content.include?('QUERY_AUTH_CODE')
			AutoRelease.perform_in(1.second,@weixin_message.Content.gsub('QUERY_AUTH_CODE:',""),@weixin_message.FromUserName,@weixin_message.Content.gsub('QUERY_AUTH_CODE:',"")+'_from_api')
		end
		""
	else
    	reply_text_message @weixin_message.Content
	end
    end
end
end
