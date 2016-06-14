class NewMedia < ActiveRecord::Base
	belongs_to :media
	belongs_to :shop_profile,foreign_key: 'shopid'
	
     def sub_media
	 NewMedia.where(sangna_config_id:self.sangna_config_id,thumb_media_id:self.thumb_media_id).where("n_type != 1")
     end
end
