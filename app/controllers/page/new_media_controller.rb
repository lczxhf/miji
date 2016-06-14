class Page::NewMediaController< Page::ApplicationController
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

	def edit
		ids = ShopSubRelation.where(shopid:params[:shopid],freeze:0).pluck(:subid)
		@shop = ShopProfile.where(shopid:ids).pluck(:shopid,:shopname)
		@sangna_config= SangnaConfig.where(shop_id:params[:shopid]).pluck(:id,:appid).first
		@page = [Media.where(del:1,sangna_config_id:@sangna_config[0]).count,ContentMedia.where(del:1,sangna_config_id:@sangna_config[0]).count]
		@page.collect! {|a| (a/5.0).ceil}
		@media = NewMedia.find(params[:id])
	end

	def update
		new_media = NewMedia.find(params[:id])
		appid = params[:appid]
		shopid = params[:shopid]
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		params.delete(:appid)
		params.delete(:shopid)
		params.delete(:controller)
		params.delete(:action)
  	 	params.delete("_method")
   		params.delete("id")
		result = JSON.parse(Sangna.update_news(sangna_config.token,new_media.thumb_media_id,'0',params))
		if result['errcode'] == 0
			media = JSON.parse(Sangna.get_or_del_forever_media(sangna_config.token,new_media.thumb_media_id))
			if media
				#NewMedia.where(n_type:1,shopid:shopid).update_all(n_type:2)
				new_media.title = params[:title]
				new_media.thumb_url = media['news_item'][0]['thumb_url']
				new_media.show_cover_pic = params[:is_cover]
				new_media.author = params[:author]
				new_media.digest = params[:digest]
				new_media.content = params[:content]
				new_media.url = media['news_item'][0]['url']
				new_media.content_source_url = params[:url]
				new_media.shopid = shopid || 0
				new_media.media_id = Media.find_by_media_id(params[:media_id]).id
				if new_media.save
					render plain: '修改成功'
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
					render plain: '添加成功'
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


	def sync
		sangna_config = SangnaConfig.where(shop_id:params[:shopid]).first	
		sync_result = 'failure'
		if sangna_config
		    result = JSON.parse Sangna.get_media_list(sangna_config.token,'news','0','20')
		    if result['total_count'] == result['item_count']	
			result['item'].each do |item|
			    if NewMedia.where(sangna_config_id:sangna_config.id,thumb_media_id:item['media_id']).where("UNIX_TIMESTAMP(updated_at) - "+item['content']['update_time'].to_s+" < -100").empty?
				item['content']['news_item'].each do |news|
				    new_media = NewMedia.find_or_initialize_by(thumb_media_id:item['media_id'],show_cover_pic:news['show_cover_pic'],sangna_config_id:sangna_config.id)
				    new_media.title = news['title']
				    new_media.author = news['author']
				    new_media.digest = news['digest']
				    new_media.content = news['content']
				    new_media.url = news['url']
				    new_media.content_source_url = news['content_source_url']
				    new_media.shopid = params[:shopid]
				    new_media.del = 1
				    media = Media.find_or_initialize_by(media_id:news['thumb_media_id'],m_type:'image',sangna_config_id:sangna_config.id)
				    if media.id.nil?
					img = MiniMagick::Image.read Sangna.get_or_del_forever_media(sangna_config.token,news['thumb_media_id'])
					img.format 'png'
					media.local_url = img
					media.del = 1
					media.save!
				    end
				    new_media.media_id = media.id
				    if new_media.save
					sync_result = 'success'
				    end 
				end
			    end
			end
		    end
		end
		render plain: sync_result	
	end
	def check
		shop_member = ShopMember.find(params[:shopid])
		if !shop_member.auth
			redirect_to "http://mijiclub.com"
		end
	end
end
