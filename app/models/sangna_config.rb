class SangnaConfig < ActiveRecord::Base
	def self.generate_config(json)
		sangna_config = SangnaConfig.find_or_initialize_by(appid:json['authorization_info']['authorizer_appid'])
		sangna_config.token=json['authorization_info']['authorizer_access_token']
		sangna_config.del=1
		sangna_config.shop_id = params[:id]
		sangna_config..refresh_token=json['authorization_info']['authorizer_refresh_token']
		# qrcode=Sangna.get_qrcode(sangna_config.token,'QR_LIMIT_SCENE',"","1")
		# qrcode=Sangna.fetch_qrcode(qrcode['ticket'])
		# img=MiniMagick::Image.read qrcode
		# img.format 'png'
		# img.resize '190x190'
		# sangna_config.qr_code
		arr=[]
		json['authorization_info']['func_info'].each do |a|
			arr<<a['funcscope_category']['id']
		end
		sangna_config.func_info=arr.join(',')
		sangna_config.save
		# change_qrcode(auth_code)
	end

	def self.get_sangna_config_token
		#
		#
		#还没写
	end
	def self.set_industry(token)
		 one='39'
      	 two='24'
      	 Sangna.set_industry(token,one,two)
	end

	def self.add_template(token,id)

		template_list = Sangna.get_template_list(token)
		template_list = template_list['template_list'].collect {|a| a['template_id']}
		arr = TemplateMessage.where(id:template_list).pluck(:template_number_id)
		industry_type = 1 #桑拿会所
		template_number = TemplateNumber.where(industry_type:industry_type).where("id not in (#{arr.join(',')})").pluck(:number)
		template_number.each do |number|
			if templete_id = Sangna.add_template(token,number)['template_id']
				t_message=TemplateMessage.new
      			t_message.templete_id=templete_id
      			t_message.sangna_config_id=id
      			t_message.templete_number_id=number
      			t_message.save!
			end
		end
		
	end

	def self.set_menu(token)
		body=""
		Sangna.set_menu(token,body)
	end
	
	def change_qrcode(sangna_config)
				MiniMagick::Tool::Convert.new do |convert|
							# convert << "+append"
							#	convert << Rails.root.join("public","images","gaokede.png")
							#	convert << Rails.root.join("public","images","zhiwu.png")	
							#	convert << Rails.root.join("public","images","result.png")	
							convert << '-size'
							convert << '380x190'
							convert << '-strip'
							convert << 'xc:none'
							convert <<  Rails.root.to_s+'/public'+sangna_config.qr_code.url
							convert << '-geometry'
							convert << '+0+0'
							convert << '-composite'
							convert << Rails.root.join("public","images","zhiwu.png")	
							convert << '-geometry'
							convert << '+190+0'
							convert << '-composite'
							convert << Rails.root.to_s+'/public'+sangna_config.qr_code.url
				end
	end
end