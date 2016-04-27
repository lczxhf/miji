class Page::MediaController < ApplicationController
layout 'new_media_layout'

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
		if params[:page].to_i <= 0
		     params[:page] = 1
		end
		if params[:page_num].to_i <= 0
			params[:page_num] = 12
		end
		if !params[:sangna_config_id]
			params[:sangna_config_id] = SangnaConfig.find_by_shop_id(params[:shopid]).id
		end
		if params[:m_type] = "all"
		@media = Media.where(sangna_config_id:params[:sangna_config_id]).order(updated_at: :desc).offset((params[:page].to_i-1)*params[:page_num].to_i).limit(params[:page_num]).select(:local_url,:media_id,:id)	
		else
		@media = Media.where(sangna_config_id:params[:sangna_config_id],del:1).order(updated_at: :desc).offset((params[:page].to_i-1)*params[:page_num].to_i).limit(params[:page_num]).select(:local_url,:media_id,:id)	
		end
		respond_to do |format|
	    	format.html
	    	format.json {render json: @media}
	    end
	end

	def destroy
		media = Media.find(params[:id])
		media.del = 2
		if media.save
			render plain: %{{"errCode":1,"errMsg":"success"}}
		else
			render plain: %{{"errCode":0,"errMsg":"failure"}}
		end
	end
end
