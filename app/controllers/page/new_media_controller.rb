class Page::NewMediaController< ApplicationController
	layout 'new_media_layout'
	before_action :check,only: [:index,:new,:create]
	def index
		if params[:page].to_i <= 0
		     params[:page] = 1
		end
		if params[:page_num].to_i <= 0
			params[:page_num] = 16
		end
		@sangna_config= SangnaConfig.where(shop_id:params[:shopid]).pluck(:id,:appid).first
		@news = NewMedia.includes(:media,:shop_profile).where(sangna_config_id:@sangna_config[0],del:1).order(created_at: :desc).offset((params[:page].to_i-1)*params[:page_num].to_i).limit(params[:page_num])
		@total_page = (NewMedia.where(sangna_config_id:@sangna_config[0],del:1).count/params[:page_num].to_f).ceil
		respond_to do |format|
      		format.html # index.html.erb
      		format.json { render json: @news.to_json(:include => [:media])}
    	end
	end

	def new
		ids = ShopSubRelation.where(shopid:params[:shopid],freeze:0).pluck(:subid)
		@shop = ShopProfile.where(shopid:ids).pluck(:shopid,:shopname)
		@sangna_config= SangnaConfig.where(shop_id:params[:shopid]).pluck(:id,:appid).first
		@page = [Media.where(del:1,sangna_config_id:@sangna_config[0]).count,ContentMedia.where(del:1,sangna_config_id:@sangna_config[0]).count]
		@page.collect! {|a| (a/5.0).ceil}
	end

	def create
		puts params
		appid = params[:appid]
		shopid = params[:shopid]
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		params.delete(:appid)
		params.delete(:shopid)
		params.delete(:controller)
		params.delete(:action)
		result = JSON.parse(Sangna.upload_news(sangna_config.token,[params]))
		media_id = result['media_id']
		if media_id
			media = JSON.parse(Sangna.get_or_del_forever_media(sangna_config.token,media_id))
			if media
				#NewMedia.where(n_type:1,shopid:shopid).update_all(n_type:2)
				new_media = NewMedia.new
				new_media.title = params[:title]
				new_media.thumb_media_id = media_id
				new_media.thumb_url = media['news_item'][0]['thumb_url']
				new_media.show_cover_pic = params[:is_cover]
				new_media.author = params[:author]
				new_media.digest = params[:digest]
				new_media.content = params[:content]
				new_media.url = media['news_item'][0]['url']
				new_media.content_source_url = params[:url]
				new_media.shopid = shopid
				new_media.media_id = Media.find_by_media_id(params[:media_id]).id
				new_media.sangna_config_id = sangna_config.id
				if new_media.save
					render plain: 'success'
				else
					render plain: 'save failure'
				end
			else
				render plain: 'get failure'
			end
		else
			render plain: 'failure'
		end
	end

	def destroy
		if NewMedia.find(params[:id]).update_attribute(:del,2)
			render plain: %{{"errCode":"1","errMsg":"删除成功！"}}
		else
			render plain: %{{"errCode":"0","errMsg":"删除失败！"}}
		end
	end
	def change_normal_new
		if params[:type] == 'add'
			new_media = NewMedia.find(params[:news_id])
			if new_media
				NewMedia.where(n_type:1,shopid:params[:shopid]).update_all(n_type:2)
				new_media.n_type = 1
				if new_media.save
					render plain: %{{"errCode":"1","errMsg":"设置成功！"}}
				else
					render plain: %{{"errCode":"0","errMsg":"设置失败！"}}
				end
			end
		elsif params[:type] == 'cancel'
			if NewMedia.find(params[:news_id]).update_attribute(:n_type,2)
				render plain: %{{"errCode":"1","errMsg":"取消成功！"}}
			else
				render plain: %{{"errCode":"0","errMsg":"取消失败！"}}
			end
		end
	end

	def check
		shop_member = ShopMember.find(params[:shopid])
		if !shop_member.auth
			redirect_to "http://mijiclub.com"
		end
	end
end
