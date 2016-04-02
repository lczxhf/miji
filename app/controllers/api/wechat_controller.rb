class Api::WechatController < ApplicationController

	def upload_new_media
		
	end 
	
	def upload_image_media
		
	end

	def upload_news_img
		
	end

	private

	def check_token_expire(sangna_config)
		if Time.now - sangna_config.updated_at > 4500
			puts 'access_token invaild'
			sangna_config.refresh_gzh_token
	 	end
	end
end
