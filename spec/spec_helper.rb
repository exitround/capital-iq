$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'capital-iq'
require 'webmock/rspec'
require 'vcr'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

WebMock.disable_net_connect!
WebMock.stub_request(:post. "https://sdk.gds.standardandpoors.com/gdssdk/rest/v2/clientservice.json").to_return(:status => 200, :body => File.new(File.dirname(__FILE__) + '/responses/capiq_ibm.json'), :headers => {})

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/dish_cassettes'
  c.stub_with :webmock
end