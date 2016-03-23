class Api::MessageController < ApplicationController
	require "nokogiri"

	def receive
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		if result = ThirdParty.get_content(request.body.read)
			hash={}
			xml.xml.css('*').each do |a|
			    hash[a.node_name]=a.content
			end
			result = CommonHandle.generate_class(hash)
			render xml: result	
		end
	end
end
