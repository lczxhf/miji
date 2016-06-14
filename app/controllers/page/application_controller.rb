class Page::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  layout 'new_media_layout',only: [:index,:edit,:show,:new]
  before_action :set_shop

  private 
	
  def set_shop
	@shop_member = ShopMember.where(shopid:params[:shopid]).first if params[:shopid]
  end
end
