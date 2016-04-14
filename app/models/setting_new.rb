class SettingNew < ActiveRecord::Base
	belongs_to :sangna_config
	belongs_to :shop_member, foreign_key: 'shopid'
	belongs_to :media
end
