class Page::ArticlesController < ApplicationController
	def index
		@articles = Article.where(shop_member_id:params[:shopid])
	end

	def new
		@article = Article.new
	end

	def create
		@article = Article.create(filter_params)
	end

	def show
		@article = Article.find(params[:id])
	end

	def edit
	end

	def update
	end

	def destroy
	end


	private

	def filter_params
		params.require(:article).permit(:title, :content,:a_type,:shop_member_id,:title_img,:short_introduction)
	end
end
