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
	   
	   #customer = CustomerList.find_or_initialize_by(openid:@weixin_message.FromUserName)
	   #customer.del = 1
	   #customer.updatetime = Time.now.to_i
	   #customer.sangna_config_id = @sangna_config.id
	   #customer.subid = @sangna_config.shop_id
	   #customer.save
       if @weixin_message.EventKey.present?
            scan
       else
	    normal_new = @sangna_config.normal_new
	    if normal_new
            reply_news_message([generate_article(normal_new.title,normal_new.content,"http://callback.mijiclub.com"+normal_new.img_url.url,'http://mijiclub.com/')])
	    else
		reply_news_message([generate_article('谢谢您的关注','点击查看详情','http://callback.mijiclub.com/images/subscribe.png','http://mijiclub.com/')])
	    end
       end
	   
    end

    def unsubscribe
	   customer = CustomerList.find_or_initialize_by(openid:@weixin_message.FromUserName)
	   customer.del = 2
	   customer.updatetime = Time.now.to_i
	   customer.save
	   reply_text_message 'success'
    end

    def scan
        str = @weixin_message.EventKey.delete('qrscene_')
        customer = CustomerList.find_or_initialize_by(subid:str,openid:@weixin_message.FromUserName)
	customer.del = 1
	customer.updatetime = Time.now.to_i
	customer.sangna_config_id = @sangna_config.id
	customer.save
        arr = []
        time = Time.now.to_i
	mybase64 = Mybase64.new
	shop_profile = ShopProfile.where(shopid:str).pluck(:shopname,:district).first
        url = "http://mijiclub.com/weixin/page/technicianList.php?tm=#{time}&tkey=#{mybase64.encodeAuth(time)}&sid=#{mybase64.encodeAuth(str)}&openid=#{@weixin_message.FromUserName}&title=#{URI::escape(shop_profile[0])}"
	img_url = @sangna_config.normal_new ? "http://callback.mijiclub.com"+@sangna_config.normal_new.img_url.url : nil
        arr << generate_article(@sangna_config.normal_new.try(:title) || "#{shop_profile[1]}#{shop_profile[0]}欢迎您！点击查看WIFI密码",@sangna_config.normal_new.try(:content) || '查看店内信息 获取优惠券',img_url || 'http://callback.mijiclub.com/images/subscribe.png',url)
            GetCoupon.perform_async(@weixin_message.FromUserName,str,@sangna_config.shop_id)
            SettingNew.includes(:new_media).where(sangna_config_id:@sangna_config.id).each do |article|
                # add other articles
                arr << generate_article(article.new_media.title,article.new_media.digest,article.new_media.thumb_url,article.new_media.url)
            end
        reply_news_message(arr)
    end

    def get_location
    end
    def common_handle
    end
end
end
