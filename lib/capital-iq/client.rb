module CapitalIQ
  class Client
    ENDPOINT = 'https://sdk.gds.standardandpoors.com/gdssdk/rest/v2/clientservice.json'
    include HTTParty
    format :json

    def initialize(username, password)
      @auth = {username: username, password: password}
    end

    def base_request(requests)
      # build request
      requests = [requests] unless requests.class == Array
      request_array = requests.collect { |r| r.to_hash }
      request_body = "inputRequests=#{ {inputRequests: request_array}.to_json }"

      # send request
      response_data = self.class.post(ENDPOINT, body: request_body, basic_auth: @auth, ssl_version: :SSLv3).parsed_response

      # analyze response
      response = ApiResponse.new(response_data)
      raise ApiError if response.has_errors?
      response
    end

    def request(function, identifiers, mnemonics, properties=nil)
      mnemonics = [mnemonics] unless mnemonics.is_a? Enumerable
      identifiers = [identifiers] unless identifiers.is_a? Enumerable
      requests = []
      identifiers.each do |identifier|
        requests.unshift(*mnemonics.collect {|m| CapitalIQ::Request.new(function, identifier, m, properties)})
      end
      base_request(requests)
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^request_(.+)$/
        function = $1.upcase
        if Functions.all.include?(function)
          request(*([function]+args))
        else
          super
        end
      else
        super
      end
    end
  end

  # b/w compatibility with 0.07

  Base = Client
end