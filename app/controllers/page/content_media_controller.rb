class Page::ContentMediaController < ApplicationController
	def create
		puts params
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		check_token_expire(sangna_config)
		result = JSON.parse(Sangna.upload_news_img(sangna_config.token,params[:file],params[:file].original_filename))
		render plain: result['url'] || 'failure'
	end

	def index
	end
end
