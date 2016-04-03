class ShopProfile < ActiveRecord::Base
	self.table_name = "shop_profile"
	self.primary_key = 'shopid'
end
