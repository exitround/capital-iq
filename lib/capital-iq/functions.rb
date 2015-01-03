module CapitalIQ
  class Functions
    GDSP ||= 'GDSP'
    GDSPV ||= 'GDSPV'
    GDSG ||= 'GDSG'
    GDSHE ||= 'GDSHE'
    GDSHV ||= 'GDSHV'
    GDST ||= 'GDST'

    @all ||= Set.new([GDSP,GDSPV,GDSG,GDSHE,GDSHV,GDST])

    class << self

      attr_reader :all

      def is_array_function(function)
        function == GDSHE || function == GDSHV
      end
    end
  end
end
