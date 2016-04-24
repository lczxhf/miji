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
end
