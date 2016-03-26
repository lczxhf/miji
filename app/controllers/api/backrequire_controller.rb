class Api::BackrequireController < ApplicationController
	def get_access_token
		sangna_config = SangnaConfig.where(shop_id:params[:shopid]).first	
		if Time.now - sangna_config.updated_at > 4500
			puts 'access_token invaild'
			sangna_config.refresh_gzh_token
	 	end
		render plain: sangna_config.token
	end
end
