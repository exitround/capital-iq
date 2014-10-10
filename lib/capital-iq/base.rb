module CapitalIQ
  class Base
    ENDPOINT = 'https://sdk.gds.standardandpoors.com/gdssdk/rest/v2/clientservice.json'
    include HTTParty
    format :json

    def initialize(username, password)
      @auth = {username: username, password: password}
    end

    def request(function, identifier, mnemonic, properties)
      request_body = Request.new(function, identifier, mnemonic, properties).request
      response_data = self.class.post(ENDPOINT, body: request_body, basic_auth: @auth, ssl_version: :SSLv3).parsed_response
      response = response_data[response_data.keys.first]
      raise CapitalIQ::APIError if response == "Error Processing the Request"
      raise CapitalIQ::APIError, response.first['ErrMsg'] if response.first['ErrMsg']
      response.first
    end

    def gdst_request(identifier, mnemonic)
      response = request('GDST', identifier, mnemonic, {PERIODTYPE: "IQ_FQ"})
      response['Rows'].first['Row'].first
    end

    def gdsp_request(identifier, mnemonic)
      response = request('GDSP', identifier, mnemonic, nil)
      response['Rows'].first['Row'].first
    end

    def gdshe_request(identifier, mnemonic, properties)
      response = request('GDSHE', identifier, mnemonic, properties)
      response['Rows'].first['Row'].first
    end

    def quick_match(name)
      gdshe_request(name, 'IQ_COMPANY_ID_QUICK_MATCH', {startRank:"1", endRank:"5"})
    end

    def match_and_request(name, mnemonic)
      identifier = quick_match(name)
      gdsp_request(identifier, mnemonic)
    end

    def transaction_list(identifier)
      transaction_items = ['IQ_TR_CURRENCY', 'IQ_TR_TARGET_ID', 'IQ_TR_BUYER_ID', 'IQ_TR_SELLER_ID', 'IQ_TR_STATUS', 'IQ_TR_CLOSED_DATE', 'IQ_TR_IMPLIED_EV_FINAL']
      walk_transactions(identifier, 'IQ_TRANSACTION_LIST_MA', transaction_items)
    end

    def pe_transactions(identifier)
      transaction_items = ['IQ_PRIMARY_SIC_CODE', 'IQ_EMPLOYEES']
      walk_transactions(identifier, 'IQ_INVESTMENTS_ALL_ID', transaction_items)
    end

    private
     def walk_transactions(identifier, list_identifier, transaction_items)
      acquisitions = {}
      transaction_list = request('GDSHE', identifier, list_identifier, {startRank:"1", endRank:"20"})
      return nil if transaction_list['Rows'].first["Row"].first == 'Data Unavailable'
      transaction_list['Rows'].each do |transaction|
        acquisitions[transaction['Row'].first] = transaction_items.map {|transaction_item|
          Hash[transaction_item, request('GDSP', transaction['Row'].first, transaction_item, nil)['Rows'].map {|a|
            next if a['Row'].first == 'Data Unavailable'
            if a['Row'].first.include?(',')
              a['Row'].first.split(', ')
            else
              a['Row'].first
            end
            }.first 
          ]
        }.reduce({}, :merge)
      end
      acquisitions

     end

  end
end
