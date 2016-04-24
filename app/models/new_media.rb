class NewMedia < ActiveRecord::Base
	belongs_to :media
	belongs_to :shop_profile,foreign_key: 'shopid'

end
