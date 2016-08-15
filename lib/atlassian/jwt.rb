require "atlassian/jwt/version"
require 'jwt'

module Atlassian
  module Jwt
    class << self
      def decode(token,secret, validate = true, options = {})
        options.merge({:algorithm => 'HS256'})
        ::JWT.decode token, secret, validate, options
      end
    end
  end
end
