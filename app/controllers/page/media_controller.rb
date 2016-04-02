class Page::MediaController < ApplicationController
	def create
		puts params
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		check_token_expire(sangna_config)
		result =JSON.parse( Sangna.upload_forever_media(sangna_config.token,'image',params[:file],params[:file].original_filename))
		puts result
		if result['media_id']
			media = Media.new
			media.m_type='image'
			media.media_id = result['media_id']
			media.url = result['url']
			media.sangna_config_id = sangna_config.id
			media.save
			render plain: result['media_id']
		else
			render plain: "0"
		end
	end

	def index
	end
end
