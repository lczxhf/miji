class Media < ActiveRecord::Base
	mount_uploader :local_url,MediaUploader	
	has_many :new_media
end
