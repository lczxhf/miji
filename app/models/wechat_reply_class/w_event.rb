class WEvent
	def initialize(hash)
      @message = Message.factory hash
    end

    def handle
    	case @message.Event
    	when 'subscribe'
    		subscribe
    	when 'unsubscribe'
    		unsubscribe
    	when 'SCAN'
    		scan
    	else
    		common_handle
    	end
    end

    def subscribe
    end

    def unsubscribe
    end

    def scan
    end

    def common_handle
    end
end