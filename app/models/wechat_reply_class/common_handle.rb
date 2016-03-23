module WechatReplyClass
class CommonHandle
	def self.generate_class(hash,appid)
	  case hash['MsgType']
      when 'text'
        WText.new(hash,appid).handle
      when 'image'
        WImage.new(hash,appid).handle
      when 'location'
        WLocation.new(hash,appid).handle
      when 'link'
        WLink.new(hash,appid).handle
      when 'event'
        WEvent.new(hash,appid).handle
      else
        raise ArgumentError, 'Unknown Weixin Message'
      end
	end
end
end
