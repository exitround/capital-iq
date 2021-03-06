require 'set'
require 'ostruct'
require 'httparty'
require 'json'
require 'digest'
require 'zlib'

module CapitalIQ
end

require_relative 'capital-iq/cache'
require_relative 'capital-iq/functions'
require_relative 'capital-iq/api_error'
require_relative 'capital-iq/request'
require_relative 'capital-iq/request_result'
require_relative 'capital-iq/api_response'
require_relative 'capital-iq/client'
