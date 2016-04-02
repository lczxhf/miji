class Page::MediaController < ApplicationController
	def create
		puts params
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		result =JSON.parse( Sangna.upload_forever_media(sangna_config.token,'image',params[:file],params[:file].original_filename))
		puts result
		if result['media_id']
			media = Media.new
			media.m_type='image'
			media.media_id = result['media_id']
			media.url = result['url']
			media.sangna_config_id = sangna_config.id
			media.local_url = params[:file]
			media.save
			render plain: %{{"errCode":"1","media_id":"#{result['media_id']}","url":"#{media.local_url.thumb.url}"}}
		else
			render plain: '{"errCode":"0","errMsg":"添加失败！"}'
		end
	end

	def index
		if params[:m_type] == "all"
		media = Media.where(sangna_config_id:params[:sangna_config_id]).offset((params[:page].to_i-1)*5).limit(5).select(:local_url,:media_id,:id)	
		else
		media =	Media.where(sangna_config_id:params[:sangna_config_id],del:1).offset((params[:page].to_i-1)*5).limit(5).select(:local_url,:media_id,:id)	
		end
		render plain: media.to_json
	end
end
