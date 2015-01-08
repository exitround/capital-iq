module CapitalIQ
  class ApiResponse
    class IdentifierResultGroup
      attr_reader :identifier
      def initialize(identifier)
        @identifier = identifier
        @header_map = {}
        @results = []
      end
      def <<(result)
        raise "Result contains wrong identifier" if result.Identifier != self.identifier
        @results << result
        (result.Headers || []).each { |h| @header_map[h] = result }
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

    def initialize(response_data)
      @response_data = response_data

      @results = []
      @identifier_results = Hash.new {|hash, key| hash[key] = IdentifierResultGroup.new(key)}
      raw_results = response_data["GDSSDKResponse"]
      return if !raw_results.is_a?(Array)

      # create wrappers for each response
      @results = raw_results.collect { |r| RequestResult.new(r) }
      # build a map from header to corresponding result wrappers
      @results.each { |r| @identifier_results[r.Identifier] << r }
    end

    def has_errors?(header=nil)
      return true if @response_data.include?("Errors")
      @results.find { |r| r.has_errors?(header)}
    end

    def [](identifier)
      return nil unless @identifier_results.has_key?(identifier)
      @identifier_results[identifier]
    end

    def scalar
      return nil if @identifier_results.length == 0
      @identifier_results.first[1]
    end

    def identifiers
      @identifier_results.keys
    end

    def to_hash
      Hash[self.identifiers.collect { |id| [id, self[id]] }]
    end

    def to_s
      to_hash().to_s()
    end
  end
end