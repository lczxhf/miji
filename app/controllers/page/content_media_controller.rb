class Page::ContentMediaController < ApplicationController
	def create
		puts params
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		result = JSON.parse(Sangna.upload_news_img(sangna_config.token,params[:file],params[:file].original_filename))
		if result['url']
			puts result
			media = ContentMedia.new
			media.local_url=params[:file]
			media.wechat_url = result['url']
			media.sangna_config_id = sangna_config.id
			media.save!
			render plain: result['url']
		else
			render plain: '添加失败!'
		end
	end

	def index
	    if params[:m_type]=="all"
		media = ContentMedia.where(sangna_config_id:params[:sangna_config_id]).offset((params[:page].to_i-1)*5).limit(5).select(:local_url,:wechat_url,:id)
	    else
		media = ContentMedia.where(sangna_config_id:params[:sangna_config_id],del:1).offset((params[:page].to_i-1)*5).limit(5).select(:local_url,:wechat_url,:id)
	    end
		render plain: media.to_json
	end
end
