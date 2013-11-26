module Cucumber::ApiSteps::Methods
  extend Forwardable

  METHODS = [
    :url,
    :request,
    :get,
    :post,
    :put,
    :patch,
    :delete,
    :options,
    :head,
    :follow_redirect!,
    :header,
    :env,
    :set_cookie,
    :clear_cookies,
    :authorize,
    :basic_authorize,
    :digest_authorize,
    :last_response,
    :last_request
  ]

  def_delegators :current_session, *METHODS

  def current_session
    @current_api_steps_session ||= MockSession.new
  end

  class MockSession
    def initialize
      @headers = {}
    end

    def url v
      @conn = nil
      @url = v
    end

    def header(k,v)
      puts "= header(#{k.inspect}, #{v.inspect})"
      @headers[k.to_s] = v.to_s
    end

    def request(path, request_opts = {})
      @last_response = nil
      puts "= request(#{path.inspect}, #{request_opts.inspect}"
      @last_response = conn.run_request(request_opts[:method] || :get, path, nil, @headers) { |req|
        req.body = request_opts[:input] if request_opts.has_key?(:input)
        req.params = request_opts[:params] if request_opts.has_key?(:params)
        @headers.each do |k, v|
          req.headers[k] = v
        end
      }
    end

    def last_response
      @last_response
    end

    def conn
      @conn ||=
        begin
          require 'faraday'
          Faraday.new(url: @url)
        end
    end
  end

end
