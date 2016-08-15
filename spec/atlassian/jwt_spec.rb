require 'spec_helper'
require 'json'

describe Atlassian::Jwt do
  it 'has a version number' do
    expect(Atlassian::Jwt::VERSION).not_to be nil
  end

  # Offical Atlassian signed URL test data
  json_tests = File.read(File.expand_path('../resources/jwt-signed-urls.json', File.dirname(__FILE__)))

  test_data = JSON.parse(json_tests)
  shared_secret = test_data['secret']
    test_data['tests'].each do |test|
      it "#{test['name']}" do
        uri = URI.parse(test['signedUrl'])
        query = CGI::parse(uri.query)
        token = query['jwt'].first
        Atlassian::Jwt.decode(token,
                              shared_secret,
                              true,
                              { leeway: (3600 * 24 * 365 * 10)})
      end
    end
end
