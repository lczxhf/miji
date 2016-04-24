class Page::SettingNewsController < ApplicationController
layout 'new_media_layout'
	def index
		@normal_new = NormalNew.where(shopid:params[:shopid],del:1).first
		if @normal_new.nil?
			@normal_new = {}
			@normal_new['title'] = "欢迎您！点击查看WIFI密码"
			@normal_new['content'] = "查看店内信息 获取优惠券"
		end
		@setting_news = SettingNew.includes(new_media: :media).where(shopid:params[:shopid]).order(news_order: :asc)
	end

	def create
		if SettingNew.where(shopid:params[:shopid]).count < 9
			setting_new = SettingNew.new
			setting_new.shopid = params[:shopid]
			setting_new.sangna_config_id = SangnaConfig.where(shop_id:params[:shopid]).first.id
			setting_new.new_media_id = params[:news_id]
			if setting_new.save
				render plain: '{"errCode":1,"errMsg":'+setting_new.id.to_s+'}'
			else
				render plain: '{"errCode":0,"errMsg":"添加失败"}'
			end
		else
			render plain: '{"errCode":0,"errMsg":"只能添加9条"}'
		end
	end

	def update
		setting_new = SettingNew.find(params[:id])	
		setting_new.new_media_id = params[:news_id]
		if setting_new.save
			render plain: '{"errCode":1,"errMsg":"修改成功"}'
		else
			render plain: '{"errCode":0,"errMsg":"修改失败"}'
		end
	end

	def destroy
		SettingNew.find(params[:id]).destroy!
	end
end
