class Api::BackrequireController < ApplicationController
	def get_access_token
		sangna_config = SangnaConfig.where(shop_id:params[:shopid]).first	
		check_token_expire(sangna_config)
		render plain: sangna_config.token
	end

	def get_user_info
		customer = CustomerList.find_by_openid(params[:openid])
		check_token_expire(sangna_config)
		render plain: get_user_info(params[:openid],sangna_config.token,false)
	end




	private

	def check_token_expire(sangna_config)
		if Time.now - sangna_config.updated_at > 4500
			puts 'access_token invaild'
			sangna_config.refresh_gzh_token
	 	end
	end
end
