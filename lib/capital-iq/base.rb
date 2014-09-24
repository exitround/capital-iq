module CapitalIQ
  class Base
    include HTTParty    
    format :json

    def initialize(username, password)
      @auth = {username: username, password: password}
    end

    def request(function, identifier, mnemonic, properties)
      request_body = Request.new(function, identifier, mnemonic, properties).request
      response_data = self.class.post('https://sdk.gds.standardandpoors.com/gdssdk/rest/v2/clientservice.json', body: request_body, basic_auth: @auth, ssl_version: :SSLv3).parsed_response
      response = response_data[response_data.keys.first].first
      raise CapitalIQ::APIError, response['ErrMsg'] if response['ErrMsg']
      response
    end
    
    def gdst_request(identifier, mnemonic)
      response = request('GDST', identifier, mnemonic, {PERIODTYPE: "IQ_FQ"})
      response['Rows'].first['Row'].first
    end
    
    def quick_match(identifier)
      response = request('GDSHE', 'exitround', 'IQ_COMPANY_ID_QUICK_MATCH', {startRank:"1", endRank:"5"})
      response['Rows'].first['Row'].first
    end
    
  end
end
