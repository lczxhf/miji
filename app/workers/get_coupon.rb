 require 'sidekiq/api'
 class GetCoupon
 	include Sidekiq::Worker
 	def perform(openid,subid,shopid)
 		uri = URI('http://mijiclub.com/api/sendCoupon.php')
 		Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
 				response=http.post uri,"shopid=#{shopid}&subid=#{subid}&openid=#{openid}"

 				result = response.body
				puts result
				json = JSON.parse(result)
 				if json['errCode'] == '1001'
 					
 				end
 		end
 	end
 end
