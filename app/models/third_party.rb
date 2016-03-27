class ThirdParty
  require 'digest/sha1'
	require 'base64' 
	require 'net/http'
  require 'nokogiri'
	#@token='tiandiwang'
	#@@appid='wx31aa7bfa0ae30872'
	#@@appsecret='0c79e1fa963cd80cc0be99b20a18faeb'
	#@@encryptkey='IuvWqPHol3TrXsLYMuOKisVFjewCwIUJBJ6ucMBKjp8'
	#@@wechat_info=WechatInfo.first	

  #验证是否是微信发来的消息
	def self.check_info(timestamp,nonce,msg_encrypt,signature)
		str=[TOKEN,timestamp,nonce,msg_encrypt].sort.join
		sha1=Digest::SHA1.hexdigest(str.to_s)
		if signature == sha1
   		   return true
  		else
     	   return false
 	        end	
	end
		
	def  self.get_access_token()
    if token=Rails.cache.read(:access_token)
    else  
		  ticket=Rails.cache.read("ticket")
 	    url = 'https://api.weixin.qq.com/cgi-bin/component/api_component_token'
		  body='{"component_appid":"'+APPID+'","component_appsecret":"'+APPSECRET+'","component_verify_ticket":"'+ticket+'"}'
		  result=JSON.parse(sent_to_wechat(url,body))
			if token = result['component_access_token']
						Rails.cache.write(:access_token,token,expires_in: 60.minutes)
			end
    end
    token
	end
	
  #向微信发起post请求
	def self.sent_to_wechat(url,body)
		 uri = URI(url)
     Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
     request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
        request.body=body
        puts request.body
        response=http.request request
        response.body
     end
	end
	
  #向微信发起get请求
	def self.get_to_wechat(url)
        uri = URI(url)
        Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
          request= Net::HTTP::Get.new(uri)
          response=http.request request
					response.body
        end
  end

  def self.get_pre_auth_code
      url = 'https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token='+get_access_token
      body = '{"component_appid":"'+APPID+'"}'
      result=JSON.parse(sent_to_wechat(url,body))
      result
  end

  def self.authorize(auth_code)
      url='https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token='+Rails.cache.read(:access_token)
      body='{"component_appid":"'+APPID+'","authorization_code":"'+auth_code+'"}'
      result=ThirdParty.sent_to_wechat(url,body)
      puts result
      JSON.parse(result)
  end

  #刷新公众号的token
	def self.refresh_gzh_token(authorizer_appid,authorizer_rtoken)
		url='https://api.weixin.qq.com/cgi-bin/component/api_authorizer_token?component_access_token='+get_access_token
		body='{"component_appid":"'+APPID+'","authorizer_appid":"'+authorizer_appid+'","authorizer_refresh_token":"'+authorizer_rtoken+'"}'	
		result=sent_to_wechat(url,body)
		puts result
		JSON.parse(result)
	end
#	def self.get_pre_auth_code(token)
#		uri = URI('https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token='+token)
#                Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
#                   request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
#                   request.body='{"component_appid":"'+@@wechat_info.appid+'"}'
#                        puts request.body
#                    response=http.request request
#                    response.body
#                end
#	end	

  def self.get_content(str,timestamp,nonce,msg_signature)
      doc=Nokogiri::Slop str
      encrypt=doc.xml.Encrypt.content
      if check_info(timestamp,nonce,encrypt,msg_signature)
        result = ThirdParty.new.decrypt(encrypt)
        xml = Nokogiri::Slop result
      else
        xml = nil
      end
      xml
  end
	def decrypt(text)
      		status = 200
      		text   = Base64.strict_decode64(text)
      		text   = handle_cipher(:decrypt,Base64.strict_decode64(WECHATKEY+'='), text)
      		result = decode(text)
      		content  = result[16...result.length]
      		len_list = content[0...4].unpack("N")
      		xml_len  = len_list[0]
      		xml_content = content[4...4 + xml_len]
      		from_app_id = content[xml_len + 4...content.size]
      		if APPID != from_app_id
        	puts ("#{__FILE__}:#{__LINE__} Failure because app_id != from_app_id")
        	status = 401
      		end
      		xml_content
   end
    def encrypt(text)
      text    = text.force_encoding("ASCII-8BIT")
      random  = SecureRandom.hex(8)
      msg_len = [text.length].pack("N")
      text    = "#{random}#{msg_len}#{text}#{APPID}"
      text    = encode(text)
      text    = handle_cipher(:encrypt, Base64.strict_decode64(WECHATKEY+'='), text)
      Base64.strict_encode64(text)
    end
	 def handle_cipher(action, aes_key, text)
        cipher = OpenSSL::Cipher.new('AES-256-CBC')
        cipher.send(action)
        cipher.padding = 0
        cipher.key = aes_key
        cipher.iv  = aes_key[0...16]
        return cipher.update(text) + cipher.final
      end

	def decode(text)
     	 pad = text[-1].ord
      	pad = 0 if (pad < 1 || pad >32 )
      	size = text.size - pad
      	text[0...size]
    end	
  def encode(text)
      # 计算需要填充的位数
      amount_to_pad = 32 - (text.length % 32)
      amount_to_pad = 32 if amount_to_pad == 0
      # 获得补位所用的字符
      pad_chr = amount_to_pad.chr
      "#{text}#{pad_chr * amount_to_pad}"
  end
end


