 require 'sidekiq/api'
 class AutoRelease
        include Sidekiq::Worker
        def perform(code,openid,content)
		result = ThirdParty.authorize(code)
		puts Sangna.sent_custom_message(result['authorization_info']['authorizer_access_token'],openid,content)
        end
 end
