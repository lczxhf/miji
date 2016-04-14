class NormalNew < ActiveRecord::Base
	belongs_to :sangna_config
	belongs_to :shop_member, foreign_key: 'shopid'
 	mount_uploader :img_url,MediaUploader	
end
