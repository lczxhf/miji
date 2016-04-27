class Api::ThirdPartyController < ApplicationController
	require 'nokogiri'

	def home
		shop_member = ShopMember.find_by_shopid(params[:id])
		if shop_member.expdate==0 || (Time.now.to_i - shop_member.expdate) < 0
			@url="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{APPID}&pre_auth_code=#{Rails.cache.read(:pre_code)}&redirect_uri=http://callback.mijiclub.com/api/third_party/auth_code?id=#{params[:id]}"
 	 		render :home,:layout=>false
 	 	else
 	 			redirect_to "http://www.mijiclub.com/pay.html"
 	 	end
	end
	def receive
		puts params
		if result = ThirdParty.get_content(request.body.read,params[:timestamp],params[:nonce],params[:msg_signature])
			if result.xml.InfoType.content.to_s == 'component_verify_ticket'
			   verify_ticket = result.xml.ComponentVerifyTicket.content.to_s
			   Rails.cache.write(:ticket,verify_ticket)
			   access_token = ThirdParty.get_access_token
			   Rails.cache.write(:pre_code,ThirdParty.get_pre_auth_code["pre_auth_code"])
			else
			   appid = result.xml.AuthorizerAppid.content.to_s
			   SangnaConfig.where(appid:appid).first.update_attribute(:del,2)
			end
		else
			puts 'error'
		end
		render plain: 'success'
	end

	 def auth_code 
		puts params
		arr = ShopSubRelation.where(shopid:params[:id]).pluck(:subid) << params[:id]
	 	ShopMember.where(shopid:arr).update_all(auth:1)	
		json=ThirdParty.authorize(params[:auth_code])
		sangna_config = SangnaConfig.generate_config(json,params[:id])
		#GetUserInfo.perform_async(auth_code.token,auth_code.id)
		SangnaInfo.get_info(sangna_config.id,sangna_config.appid,params[:id])
		sangna_config.set_industry()
		sangna_config.add_template()
		sangna_config.set_menu()
		redirect_to "http://mijiclub.com/"
 	 end


	def oauth2
		if params[:code]
			url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{params[:appid]}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{APPID}&component_access_token="+ThirdParty.get_access_token
			result=JSON.parse(ThirdParty.get_to_wechat(url))
			if result["openid"]
				mybase64 = Mybase64.new
				redirect_to "http://mijiclub.com/weixin/page/myCoupons.php?sid=#{mybase64.encodeAuth(SangnaConfig.where(appid:params[:appid]).first.shop_id)}&openid=#{result['openid']}&from=weixin"
			end
		end		
	end

	def authorize
		if params[:appid]
			gzh=SangnaConfig.where(appid:params[:appid]).first
			url="https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{gzh.appid}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{APPID}&component_access_token="+ThirdParty.get_access_token
      			result=JSON.parse(ThirdParty.get_to_wechat(url))
			if result["openid"]
				url = "http://mijiclub.com/weixin/share/redEnvelope.php?sid=#{params[:sid]}&openid=#{result['openid']}"
				redirect_to url
			end
		end
	end
end
