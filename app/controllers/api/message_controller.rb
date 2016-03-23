class Api::MessageController < ApplicationController
	require "nokogiri"
	def receive
		if result = ThirdParty.get_content(request.body.read,params[:timestamp],params[:nonce],params[:msg_signature])
			hash={}
			result.xml.css('*').each do |a|
			    hash[a.node_name]=a.content
			end
			result = WechatReplyClass::CommonHandle.generate_class(hash,params[:appid])
			render xml: result	
		end
	end
end
