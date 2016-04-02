class ContentMedia < ActiveRecord::Base
	mount_uploader :local_url,MediaUploader
end
