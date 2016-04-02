class Page::NewNewdiaController < ApplicationController
	def new
		ids = ShopSubRelation.where(shopid:params[:shopid],freeze:0).pluck(:subid)
		@shop = ShopProfile.where(shopid:ids).pluck(:shopid,:shopname)
		@appid = SangnaConfig.where(shop_id:params[:shopid]).pluck(:appid).first
	end

	def create
		puts params
		appid = params[:appid]
		shopid = params[:shopid]
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		check_token_expire(sangna_config)
		params.delete(:appid)
		params.delete(:shopid)
		params.delete(:controller)
		params.delete(:action)
		result = JSON.parse(Sangna.upload_news(sangna_config.token,[params]))
		media_id = result['media_id']
		if media_id
			media = JSON.parse(Sangna.get_or_del_forever_media(sangna_config.token,media_id))
			if media
				NewMedia.where(n_type:1,shopid:shopid).update_all(n_type:2)
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
end
