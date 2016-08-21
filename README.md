# Atlassian::Jwt

This gem provides helpers for generating Atlassian specific JWT
claims. It also exposes is the
[ruby-jwt](https://github.com/jwt/ruby-jwt) gem's `encode` and `decode`
methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atlassian-jwt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atlassian-jwt

## Usage

In order to access the
[Atlassian Connect REST APIs](https://developer.atlassian.com/static/connect/docs/latest/rest-apis/)
an add-on authenticates using a JSON Web Token (JWT). The token is
generated using the add-on's secret key and contains a *claim* which
includes the add-on's key and a hashed version of the API URL the
add-on is accessing. This gem simplifies generating the claim.

### Generating a JWT Token

```ruby
require 'atlassian/jwt'

# The URL of the API call, must include the query string, if any
url = 'https://jira.atlassian.com/rest/api/latest/issue/JRA-9'
# The key of the add-on as defined in the add-on description
issuer = 'com.atlassian.example'
http_method = 'get' # The HTTP Method (GET, POST, etc) of the API call
shared_secret = '...' # "sharedSecret", returned when the add-on is installed.

claim = Atlassian::Jwt.build_claims(issuer,url,http_method)
jwt = JWT.encode(claim,shared_secret)
```

If the base URL of the API is not at the root of the site,
i.e. *https://site.atlassian.com/jira/rest/api*, you will need to pass
in the base URL to `#.build_claims`:

```
url = 'https://jira.atlassian.com/jira/rest/api/latest/issue/JRA-9'
base_url = 'https://jira.atlassian.com/jira'

claim = Atlassian::Jwt.build_claims(issuer,url,http_method,base_url)
```

The generated JWT can then be passed in an 'Authentication' header or
in the query string:

```ruby
# Header
uri = URI('https://jira.atlassian.com/rest/api/latest/issue/JRA-9')
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)
request.initialize_http_header({'Authentication' => "JWT #{jwt}"})
response = http.request(request)
```

```ruby
# Query String
uri = URI("https://jira.atlassian.com/rest/api/latest/issue/JRA-9?jwt=#{jwt}")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
```

By default the issue time of the claim is now and the expiration is 60
seconds in the future, these can be overridden:

```ruby
claim = Atlassian::Jwt.build_claims(
  issuer,
  url,
  http_method,
  base_url,
  Time.now - 60.seconds
  Time.now + 1.day
)
```

### Decoding a JWT token

The JWT from the server is usually returned a param. The underlying
Ruby JWT gem returns an array with the first element being the claim
and the second being the JWT header, which contains information about
how the JWT was encoded.

```ruby
claims, jwt_header = Atlassian::Jwt.decode(params[:jwt],shared_secret)
```

By default, the JWT gem verifies that the JWT is properly signed with
the shared secret and raises an error if it's not. However, sometimes
is necessary to read the JWT first to determine which shared secret is
needed. In this case, use nil for the shared secret and follow it with
`false` to tell the gem to to verify the signature.

```ruby
claims, jwt_header = Atlassian::Jwt.decode(params[:jwt],nil,false)
```

See the [ruby-jwt doc](https://github.com/jwt/ruby-jwt) for additional
details.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on Bitbucket at
https://bitbucket.org/atlassian/atlassian-jwt-ruby.
