class Page::ShopArticlesController < ApplicationController
	def index
		@articles = ShopArticle.where(shop_member_id:params[:shopid])
	end

	def new
		@article = ShopArticle.new
		ids = ShopSubRelation.where(shopid:params[:shopid]).pluck(:subid)
		@shop = ShopProfile.where(shopid:ids).pluck(:shopid,:shopname)
		@appid = SangnaConfig.where(shop_id:params[:shopid]).pluck(:appid).first
	end

	def create
		puts params
		article = ShopArticle.new
		article.title = params[:title]
		article.content = params[:content]
		article.title_img = params[:title_img]
		article.short_introduction = params[:short_introduction]
		article.a_type = 1
		shop = ShopProfile.where(shopname:params[:shop_name]).first
		response['Access-Control-Allow-Origin'] = '*'
		if shop
			article.shop_member_id = shop.shopid
			if article.save
				ShopArticle.where(shop_member_id:shop.shopid,a_type:1).where.not(id:article.id).update_all(a_type:2)
				render plain: '添加成功'
			else
				render plain: '添加失败'
			end
		else
			render plain: '店名不存在'
		end
	end

	def show
		@article = ShopArticle.find(params[:id])
	end

	def edit
	end

	def update
	end

	def destroy
	end


	private

	def filter_params
		params.require(:shop_article).permit(:title, :content,:a_type,:shop_member_id,:title_img,:short_introduction)
	end
end
