 require 'sidekiq/api'
 class GetCoupon
 	include Sidekiq::Worker
 	def perform(openid,subid,shopid)
 		uri = URI('http://mijiclub.com/api/sendCoupon.php')
 		Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
 				request = Net::HTTP::Post.new uri,{'Content-Type'=>'application/json'}
 				request.body = "{'subid':'#{subid}','shopid':'#{shopid}','openid':'#{openid}'}"
 				response=http.request request
 				json = JSON.parse(response)
 				if json['errCode'] == '1001'
 					
 				end
 		end
 	end
 end