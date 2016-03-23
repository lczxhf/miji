class CommonHandle
	def self.generate_class(hash)
    puts hash.to_json
	  case hash['MsgType']
      when 'text'
        WText.new(hash).handle
      when 'image'
        WImage.new(hash).handle
      when 'location'
        WLocation.new(hash).handle
      when 'link'
        WLink.new(hash).handle
      when 'event'
        WEvent.new(hash).handle
      else
        raise ArgumentError, 'Unknown Weixin Message'
      end
	end
end