module CapitalIQ
  class Request
    attr_reader :function, :identifier, :mnemonic, :properties

    def initialize(function, identifier, mnemonic, properties = nil)
      @function = function
      @identifier = identifier
      @mnemonic = mnemonic
      @properties = properties

      @hash = {
          function: self.function,
          identifier: self.identifier,
          mnemonic: self.mnemonic
      }
      @hash[:properties] = properties unless properties.nil?
    end

    def to_hash
      @hash
    end

  end
end
