module CapitalIQ
  class ApiResponse
    def initialize(response_data)
      @results = []
      @header_map = {}
      @response_data = response_data
      raw_results = response_data["GDSSDKResponse"]
      return if raw_results.class != Array

      # create wrappers for each response
      @results = raw_results.collect { |r| RequestResult.new(r) }
      # build a map from header to corresponding result wrappers
      @results.each { |r| (r.Headers || []).each { |h| @header_map[h] = r } }
    end

    def has_errors?(header=nil)
      return true if @response_data.include?("Errors")
      @results.find { |r| r.has_errors?(header)}
    end

    def headers
      @header_map.keys
    end

    def [](header)
      @header_map[header][header]
    end

    def to_hash
      Hash[self.headers.collect { |h| [h, self[h]] }]
    end

    def to_s
      to_hash().to_s()
    end
  end
end