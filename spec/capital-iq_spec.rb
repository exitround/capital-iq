require File.expand_path(File.dirname(__FILE__) + '/../lib/capital-iq.rb')

describe "CapitalIq" do
  ci = CapitalIQ::Client.new(ENV['CAPIQ_USER'], ENV['CAPIQ_PWD'], Redis.new)

  # Call based on a request object
  req = CapitalIQ::Request.new(CapitalIQ::Functions::GDSHE, 'microsoft', 'IQ_COMPANY_ID_QUICK_MATCH')
  res = ci.base_request(req)

  # Shortened form
  res = ci.request_gdshe('microsoft', 'IQ_COMPANY_ID_QUICK_MATCH', {startRank:1, endRank:20})
  # Use 'scalar' if you query on a single identifier
  # When using GDSHE or GDSHV, value for a given mnemonic will be an array (that's why we use 'first')
  ms_id = res.scalar['IQ_COMPANY_ID_QUICK_MATCH'].first

  # Multiple identifier / single mnemonic requests
  res = ci.request_gdshe(['microsoft', 'google'], 'IQ_COMPANY_ID_QUICK_MATCH', {startRank:1, endRank:20})
  ms_id = res['microsoft']['IQ_COMPANY_ID_QUICK_MATCH'].first
  g_id = res['google']['IQ_COMPANY_ID_QUICK_MATCH'].first


  # Mulple identifier / multiple mnemonic queries
  res = ci.request_gdsp([ms_id, g_id], %w(IQ_COMPANY_WEBSITE IQ_COMPANY_NAME IQ_BUSINESS_DESCRIPTION))
  # Use the mnemonic name to retrieve its value or 'to_hash' to retrieve all mnemonic values for a given identifier
  ms_name = res[ms_id]['IQ_COMPANY_NAME'] # signle value
  ms_data = res[ms_id].to_hash # all mnemonics for ms_id
  g_data = res[g_id].to_hash # all mnemonics for g_id

  # puts ms_data, g_data
end
