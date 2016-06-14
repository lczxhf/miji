class Page::ContentMediaController < Page::ApplicationController
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
			render plain: %{{"errCode":"1","local_url":"#{media.local_url.url}","wechat_url":"#{result['url']}"}}
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
	    if params[:m_type]=="all"
		@media = ContentMedia.where(sangna_config_id:params[:sangna_config_id]).order(upadted_at: :desc).offset((params[:page].to_i-1)*params[:page_num].to_i).limit(params[:page_num]).select(:local_url,:wechat_url,:id)
	    else
		#@media = ContentMedia.where(sangna_config_id:params[:sangna_config_id],del:1).order(updated_at: :desc).offset((params[:page].to_i-1)*params[:page_num].to_i).limit(params[:page_num]).select(:local_url,:wechat_url,:id)
		@media = ContentMedia.where(sangna_config_id:params[:sangna_config_id]).order(updated_at: :desc).page(params[:page]).per(params[:page_num])
	    end
	    respond_to do |format|
	    	format.html
	    	format.json {render json: @media}
	    end
	end

	def destroy
		media = ContentMedia.find(params[:id])
		if media.destroy
			render plain: %{{"errCode":1,"errMsg":"success"}}
		else
			render plain: %{{"errCode":0,"errMsg":"failure"}}
		end
	end
end
