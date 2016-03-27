class ShopMember < ActiveRecord::Base
	self.table_name = "shop_member"
	self.primary_key = 'shopid'
	self.inheritance_column = :foo
	has_many :articles
	has_one :shop_profile , foreign_key: 'shopid'
end
