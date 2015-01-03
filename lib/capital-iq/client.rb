require 'set'
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

    def request(function, identifier, mnemonics, properties=nil)
      mnemonics = [mnemonics] unless mnemonics.class == Array
      requests = mnemonics.collect {|m| CapitalIQ::Request.new(function, identifier, m, properties)}
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

    DEFAULT_MA_MNEMONICS = %w(
        IQ_TR_CURRENCY IQ_TR_TARGET_ID IQ_TR_BUYER_ID IQ_TR_SELLER_ID
        IQ_TR_STATUS IQ_TR_CLOSED_DATE IQ_TR_IMPLIED_EV_FINAL
    )
    DEFAULT_MA_PROPERTIES = {startRank:"1", endRank:"10"}

    def ma_transactions(identifier, mnemonics=DEFAULT_MA_MNEMONICS, properties=DEFAULT_MA_PROPERTIES)
      transaction_ids = self.request_gdshe(identifier, 'IQ_TRANSACTION_LIST_MA', properties)
      transaction_ids = transaction_ids['IQ_TRANSACTION_LIST_MA']
      result = {}
      transaction_ids.each do |tid|
        res = self.request_gdsp(tid, mnemonics)
        result[tid] = res.to_hash
      end
      result
    end
  end
end