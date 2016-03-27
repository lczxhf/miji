module WechatReplyClass
class WEvent
	include ReplyWeixinMessage
	def initialize(hash,appid)
      @weixin_message = Message.factory hash
      @sangna_config = SangnaConfig.find_by_appid(appid)
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
        arr << generate_article('欢迎您！点击查看WIFI密码','查看店内信息 获取优惠券','http://callback.mijiclub.com/images/subscribe.png',url)
        shop_id = ShopSubRelation.where(subid:str).pluck(:shopid).first
        if shop_id
            #GetCoupon.perform_async(@weixin_message.FromUserName,str,shop_id)
            ids = ShopSubRelation.where(shopid:shop_id).pluck(:subid)
            articles = Article.where(shop_member_id:ids,a_type:1,del:1)
            url_article = "http://callback.mijiclub.com/page/"
            articles.each do |article|
                # add other articles
                arr << generate_article(article.title,article.short_introduction,article.title_img.thumb.url,url_article+article.id.to_s)
            end
        end
        reply_news_message(arr)
    end

    def common_handle
    end
end
end
