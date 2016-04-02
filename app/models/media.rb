class Media < ActiveRecord::Base
	mount_uploader :local_url,MediaUploader	
end
