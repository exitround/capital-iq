module CapitalIQ
  class ApiError < StandardError
    attr_reader :response_data
    def initialize(response_data)
      @response_data = response_data
      super("Capital IQ API returned an error. Response content: #{self.inspect}")
    end

    def inspect
      {response_data: self.response_data}.to_json
    end
  end
end
