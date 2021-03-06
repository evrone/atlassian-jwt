require 'spec_helper'
require 'json'

BASE_URL = ''
JWT_OPTS = {
  leeway: (3600 * 24 * 365 * 10) # 10 years of leeway -- the JWT gem verifies the token expiry time
}

describe Atlassian::Jwt do
  it 'has a version number' do
    expect(Atlassian::Jwt::VERSION).not_to be nil
  end

  it 'passes encode through to "ruby-jwt' do
    Atlassian::Jwt.encode({test: true}, 'secret', 'HS256')
  end

  it 'generates claims' do
    url = 'https://example.atlassian.com/jira/projects'
    issuer = 'com.atlassian.test'

    now = Time.now.to_i
    qsh = Digest::SHA256.hexdigest(
      Atlassian::Jwt.create_canonical_request(url, 'get', BASE_URL)
    )

    expected_claim = {
      iss: 'com.atlassian.test',
      iat: now,
      exp: now + 60,
      qsh: qsh
    }

    claim = Atlassian::Jwt.build_claims(issuer, url, 'get', BASE_URL, now, now + 60)
    expect(claim).to eq expected_claim
  end

  # Offical Atlassian signed URL test data
  json_tests = File.read(File.expand_path('../resources/jwt-signed-urls.json', File.dirname(__FILE__)))

  test_data = JSON.parse(json_tests)
  shared_secret = test_data['secret']

  test_data['tests'].each do |test|
    signed_url = test['signedUrl']
    signed_uri = URI.parse(signed_url)
    token = CGI::parse(signed_uri.query)['jwt'].first

    it "#{test['name']} - Decode" do
      Atlassian::Jwt.decode(token,
                            shared_secret,
                            true,
                            JWT_OPTS)
    end

    it "#{test['name']} - Canonical URL" do
      canonical_uri = Atlassian::Jwt.create_canonical_request(signed_url, 'GET', BASE_URL)

      # Remote the jwt query param from the signed URL to get the original
      expect(canonical_uri).to eq test['canonicalUrl']
    end

    it "#{test['name']} - QSH match" do
      expected_qsh = Atlassian::Jwt.create_query_string_hash(signed_url, 'GET', BASE_URL)

      decoded_token = Atlassian::Jwt.decode(token,
                            shared_secret,
                            true,
                            JWT_OPTS).first

      expect(expected_qsh).to eq decoded_token['qsh']
    end
  end
end
