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
       if @weixin_message.EventKey.present?
            scan
       else
            reply_news_message([generate_article('欢迎关注','xxxxx','http://callback.mijiclub.com/images/subscribe.png','http://mijiclub.com/')])
       end
	   
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
        str = @weixin_message.EventKey.delete('qrscene_')
        arr = []
        arr << generate_article('我是第一条图文消息，请点击我','xxxxx','http://callback.mijiclub.com/images/subscribe.png','http://mijiclub.com/')
        arr << generate_article('我是第二条图文消息，请点击我','aaaaaaa','http://callback.mijiclub.com/images/Meinv.png','http://callback.mijiclub.com/api/third_party/home')
        arr << generate_article('我是第三条图文消息，请点击我','aaaaaaa','http://callback.mijiclub.com/images/Meinv.png','http://callback.mijiclub.com/api/third_party/home')
        arr << generate_article('我是第四条图文消息，请点击我','aaaaaaa','http://callback.mijiclub.com/images/Meinv.png','http://callback.mijiclub.com/api/third_party/home')
        reply_news_message(arr)
    end

    def common_handle
    end
end
end
