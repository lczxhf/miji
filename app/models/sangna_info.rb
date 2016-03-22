class SangnaInfo < ActiveRecord::Base

	def self.get_info(sangna_config_id,appid)
		sangna_info = SangnaInfo.find_or_initialize_by(sangna_config_id:sangna_config_id)
		result = Sangna.get_gzh_info(appid)['authorizer_info']
		sangna_info.nickname=result['nick_name']
		sangna_info.headimgurl=result['head_img']
		sangna_info.service_type=result['service_type_info']['id']
		sangna_info.verify_type=result['verify_type_info']['id']
		sangna_info.user_name=result['user_name']
		sangna_info.alias=result['alias']
		sangna_info.qrcode_url=result['qrcode_url']
		sangna_info.save
	end
end