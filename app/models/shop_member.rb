class ShopMember < ActiveRecord::Base
	self.table_name = "shop_member"
	self.primary_key = 'shopid'
	has_many :articles
end
