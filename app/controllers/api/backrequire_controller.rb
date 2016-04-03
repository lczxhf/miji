class Api::BackrequireController < ApplicationController
	def get_access_token
		sangna_config = SangnaConfig.where(shop_id:params[:shopid]).first	
		render plain: sangna_config.token
	end

end
