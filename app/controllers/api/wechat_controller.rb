class Api::WechatController < ApplicationController

	def upload_new_media
		puts params
		render plain: 'success'
	end
	
	def upload_image_media
		puts params
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		check_token_expire(sangna_config)
		puts  params[:file].orginal_filename
		result = Sangna.upload_forever_media(sangna_config.token,'image',params[:file],params[:file]['original_filename'])
		puts result
		if result['media_id']
			media = Media.new
			media.m_type='image'
			media.media_id = result['media_id']
			media.url = result['url']
			media.sangna_config_id = sangna_config.id
			media.save
			render json: '{"respCode":"1","msg":"'+result['url']+'"}'
		else
			render json: '{"respCode":""0","msg":"'+result['errmsg']+'"}'
		end
	end

	private

	def check_token_expire(sangna_config)
		if Time.now - sangna_config.updated_at > 4500
			puts 'access_token invaild'
			sangna_config.refresh_gzh_token
	 	end
	end
end
