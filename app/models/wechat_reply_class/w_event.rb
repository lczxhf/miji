module WechatReplyClass
class WEvent
	include ReplyWeixinMessage
	def initialize(hash,appid)
      @weixin_message = Message.factory hash
	@appid = appid
    end

    def handle
    	case @weixin_message.Event
    	when 'subscribe'
    		subscribe
    	when 'unsubscribe'
    		unsubscribe
    	when 'SCAN'
    		scan
    	else
    		common_handle
    	end
    end

    def subscribe
	sangna_config = SangnaConfig.find_by_appid(@appid)
	customer = CustomerList.find_or_initialize_by(openid:@weixin_message.FromUserName)
	customer.del = 1
	customer.updatetime = Time.now.to_i
	customer.sangna_config_id = sangna_config.id
	customer.subid = sangna_config.shop_id
	customer.save
	reply_text_message 'success'
    end

    def unsubscribe
	sangna_config = SangnaConfig.find_by_appid(@appid)
	customer = CustomerList.find_or_initialize_by(openid:@weixin_message.FromUserName)
	customer.del = 2
	customer.updatetime = Time.now.to_i
	customer.sangna_config_id = sangna_config.id
	customer.subid = sangna_config.shop_id
	customer.save
	reply_text_message 'success'
    end

    def scan
    end

    def common_handle
    end
end
end
