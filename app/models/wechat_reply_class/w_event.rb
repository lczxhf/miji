module WechatReplyClass
class WEvent
	include ReplyWeixinMessage
	def initialize(hash,appid)
      @weixin_message = Message.factory hash
      @sangna_config = SangnaConfig.find_by_appid(appid)
    end

    def handle
	if @weixin_message.ToUserName == 'gh_3c884a361561'
		reply_text_message @weixin_message.Event+"from_callback"
	else
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
    end

    def subscribe
	   
	   customer = CustomerList.find_or_initialize_by(openid:@weixin_message.FromUserName)
	   customer.del = 1
	   customer.updatetime = Time.now.to_i
	   customer.sangna_config_id = @sangna_config.id
	   customer.subid = @sangna_config.shop_id
	   customer.save
       if @weixin_message.EventKey.present?
            scan
       else
            reply_news_message([generate_article('谢谢您的关注','点击查看详情','http://callback.mijiclub.com/images/subscribe.png','http://mijiclub.com/')])
       end
	   
    end

    def unsubscribe
	   customer = CustomerList.find_or_initialize_by(openid:@weixin_message.FromUserName)
	   customer.del = 2
	   customer.updatetime = Time.now.to_i
	   customer.sangna_config_id = @sangna_config.id
	   customer.subid = @sangna_config.shop_id
	   customer.save
	   reply_text_message 'success'
    end

    def scan
        
        str = @weixin_message.EventKey.delete('qrscene_')

        arr = []
        time = Time.now.to_i
	    mybase64 = Mybase64.new
        url = "http://mijiclub.com/weixin/page/technicianList.php?tm=#{time}&tkey=#{mybase64.encodeAuth(time)}&sid=#{mybase64.encodeAuth(str)}&openid=#{@weixin_message.FromUserName}"
	shop_profile = ShopProfile.where(shopid:str).pluck(:shopname,:district).first
        arr << generate_article("#{shop_profile[1]}#{shop_profile[0]}欢迎您！点击查看WIFI密码",'查看店内信息 获取优惠券','http://callback.mijiclub.com/images/subscribe.png',url)
        shop_id = ShopSubRelation.where(subid:str).pluck(:shopid).first
        if shop_id
            GetCoupon.perform_async(@weixin_message.FromUserName,str,shop_id)
            ids = ShopSubRelation.where(shopid:shop_id).pluck(:subid)
            articles = NewMedia.where(shopid:ids,n_type:1,del:1)
            articles.each do |article|
                # add other articles
                arr << generate_article(article.title,article.digest,article.thumb_url,article.url)
            end
        end
        reply_news_message(arr)
    end

    def get_location
    end
    def common_handle
    end
end
end
