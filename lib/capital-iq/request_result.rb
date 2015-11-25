module CapitalIQ
  class RequestResult < OpenStruct
    def initialize(raw_result)
      @raw_result = raw_result
      super raw_result
    end

    def has_errors?(header=nil)
      (self.ErrMsg.to_s.strip != "") && (header.nil? || header.in?(self.Headers))
    end

    def [](header)
      result = value_array(header)
      return result if Functions.is_array_function(self.Function)
      result.first
    end

    private
    def value_array(header)
      header_idx = self.Headers.index(header)
      raise ArgumentError, "Unknown header '#{header}'" if header_idx.nil?
      self.Rows.collect do |row|
        v = row["Row"][header_idx]
        v == 'Data Unavailable' ? nil : v
      end
    end
  end
end