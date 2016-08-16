require "atlassian/jwt/version"
require 'jwt'

module Atlassian
  module Jwt
    class << self
      CANONICAL_QUERY_SEPARATOR = '&'
      ESCAPED_CANONICAL_QUERY_SEPARATOR = '%2F'

      def decode(token,secret, validate = true, options = {})
        options.merge({:algorithm => 'HS256'})
        ::JWT.decode token, secret, validate, options
      end

      def create_canonical_request(uri,http_method,base_uri)
        uri = URI.parse(uri) unless uri.kind_of? URI
        base_uri = URI.parse(base_uri) unless base_uri.kind_of? URI

        path = canonicalize_uri(uri, base_uri)

        [http_method.upcase,
         canonicalize_uri(uri, base_uri),
         canonicalize_query_string(uri.query)
        ].join(CANONICAL_QUERY_SEPARATOR)
      end

      def canonicalize_uri(uri, base_uri)
        path = uri.path.sub(/^#{base_uri.path}/,'')
        path = '/' if path.nil? || path.empty?
        path = '/' + path unless path.start_with? '/'
        path.chomp!('/') if path.length > 1
        path.gsub(CANONICAL_QUERY_SEPARATOR,ESCAPED_CANONICAL_QUERY_SEPARATOR)
      end

      def canonicalize_query_string(query)
        return '' if query.nil? || query.empty?
        query = CGI::parse(query)
        query.delete('jwt')
        query.each do |k, v|
          query[k] = v.map {|a| CGI.escape a }.join(',') if v.is_a? Array
          query[k].gsub!('+','%20') # Use %20, not CGI.escape default of "+"
          query[k].gsub!('%7E','~') # Unescape "~" per JS tests
        end
        query = Hash[query.sort]
        query.map {|k,v| "#{CGI.escape k}=#{v}" }.join('&')
      end
    end
  end
end
