require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'dotenv'

require File.expand_path(File.dirname(__FILE__) + '/../lib/capital-iq.rb')

Dotenv.load

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end

describe "CapitalIq" do
  VCR.use_cassette("spec") do
    client = CapitalIQ::Client.new(ENV['CAPIQ_USER'], ENV['CAPIQ_PWD'])

    # Call based on a request object
    # All requests passed to the base_request method are executed withing one roundtrip
    req1 = CapitalIQ::Request.new(CapitalIQ::Functions::GDSHE, 'microsoft', 'IQ_COMPANY_ID_QUICK_MATCH')
    req2 = CapitalIQ::Request.new(CapitalIQ::Functions::GDSHE, 'google', 'IQ_COMPANY_ID_QUICK_MATCH')
    res = client.base_request([req1, req2])

    # Shortened form - no need to create request objects explicitly, although they do get created underneath:
    res = client.request_gdshe('microsoft', 'IQ_COMPANY_ID_QUICK_MATCH', {startRank:1, endRank:20})

    # Returned values are accessed by identifier and mnemonic:
    res_val = res['microsoft']['IQ_COMPANY_ID_QUICK_MATCH']

    # When using GDSHE or GDSHV, the result is represented by an array (so we'll use 'first' here)
    ms_id = res_val.first

    # You can use 'scalar' when querying on a single identifier, so we can shorten the whole thing to:
    ms_id = res.scalar['IQ_COMPANY_ID_QUICK_MATCH'].first

    # Multiple identifier / single mnemonic requests
    # This example generates two requests
    res = client.request_gdshe(['microsoft', 'google'], 'IQ_COMPANY_ID_QUICK_MATCH', {startRank:1, endRank:20})
    ms_id = res['microsoft']['IQ_COMPANY_ID_QUICK_MATCH'].first
    google_id = res['google']['IQ_COMPANY_ID_QUICK_MATCH'].first

    # Multiple identifier / multiple mnemonic queries
    # This call generates (2 identifiers times 3 mnemonics) = 6 requests (they're still executed in a batch)
    res = client.request_gdsp([ms_id, google_id], %w(IQ_COMPANY_WEBSITE IQ_COMPANY_NAME IQ_BUSINESS_DESCRIPTION))
    # You can use the 'to_hash' method to retrieve all mnemonic values for a given identifier
    ms_data = res[ms_id].to_hash # all mnemonics for ms_id
    # Or you can retrieve all values for all identifiers
    google_data = res[google_id].to_hash # all mnemonics for google_id
  end
  it "raises ApiError when request is invalid" do
    VCR.use_cassette("error") do
      client = CapitalIQ::Client.new(ENV['CAPIQ_USER'], ENV['CAPIQ_PWD'])
      expect {client.request_gdshe("no such id", "no such mnemonic")}.to raise_error(CapitalIQ::ApiError)
    end
  end
end
