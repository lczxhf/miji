class Api::WechatController < ApplicationController

	def upload_new_media
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
	
	def upload_image_media
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

	def upload_news_img
		puts params
		sangna_config = SangnaConfig.find_by_appid(params[:appid])
		check_token_expire(sangna_config)
		result = JSON.parse(Sangna.upload_news_img(sangna_config.token,params[:file],params[:file].original_filename))
		render plain: result['url'] || 'failure'
	end

	private

	def check_token_expire(sangna_config)
		if Time.now - sangna_config.updated_at > 4500
			puts 'access_token invaild'
			sangna_config.refresh_gzh_token
	 	end
	end
end
