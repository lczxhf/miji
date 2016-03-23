class Api::ThirdPartyController < ApplicationController
	require 'nokogiri'

	def home
		@url="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{APPID}&pre_auth_code=#{Rails.cache.read(:pre_code)}&redirect_uri=http://callback.mijiclub.com/api/third_party/auth_code?id=#{params[:id]}"
 	 	render :home,:layout=>false
	end
	def receive
		puts params
		if result = ThirdParty.get_content(request.body.read)
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
	 	ShopMember.where(id:arr).update_all(auth:1)	
		json=ThirdParty.authorize(params[:auth_code])
		sangna_config = SangnaConfig.generate_config(json,params[:id])
		#GetUserInfo.perform_async(auth_code.token,auth_code.id)
		SangnaInfo.get_info(sangna_config.id,sangna_config.appid)
		SangnaConfig.set_industry(sangna_config.token)
		SangnaConfig.add_template(sangna_config.token,sangna_config.id)
		#SangnaConfig.set_menu(sangna_config.token)
		redirect_to "mijiclub.com"
 	 end
end
