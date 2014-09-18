module CapitalIQ
  class Request
    attr_reader :request
    
    def initialize(function, identifier, mnemonic, properties)
      request_hash =  {inputRequests:[
        {function:function, identifier: identifier, mnemonic: mnemonic}
      ]}
      request_hash.merge!({properties: properties}) if properties
      @request = "inputRequests=" + request_hash.to_json
    end
    
  end
end
