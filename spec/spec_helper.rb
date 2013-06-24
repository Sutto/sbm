ENV['REDIS_URL'] ||= "redis://127.0.0.1:6379/#{ENV['REDIS_TEST_DATABASE'] || 9}"

require 'sbm'
require 'rr'

RSpec.configure do |config|
  config.mock_with :rr
  config.before(:each) { Redis.current.flushdb }
end
