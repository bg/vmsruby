# SOAP4R - net/http wrapper
# Copyright (C) 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'net/http'


module SOAP


class NetHttpClient

  SSLEnabled = begin
      require 'net/https'
      true
    rescue LoadError
      false
    end

  attr_reader :proxy
  attr_accessor :no_proxy
  attr_accessor :debug_dev
  attr_accessor :ssl_config		# ignored for now.
  attr_accessor :protocol_version	# ignored for now.

  def initialize(proxy = nil, agent = nil)
    @proxy = proxy ? URI.parse(proxy) : nil
    @agent = agent
    @debug_dev = nil
    @session_manager = SessionManager.new
    @no_proxy = nil
  end

  def test_loopback_response
    raise NotImplementedError.new("not supported for now")
  end
  
  def proxy=(proxy_str)
    if proxy_str.nil?
      @proxy = nil
    else
      @proxy = URI.parse(proxy_str)
      if @proxy.scheme == nil or @proxy.scheme.downcase != 'http' or
	  @proxy.host == nil or @proxy.port == nil
	raise ArgumentError.new("unsupported proxy `#{proxy_str}'")
      end
      @proxy
    end
  end

  def set_basic_auth(uri, user_id, passwd)
    # net/http does not handle url.
    @basic_auth = [user_id, passwd]
  end

  def set_cookie_store(filename)
    raise NotImplementedError.new
  end

  def save_cookie_store(filename)
    raise NotImplementedError.new
  end

  def reset(url)
    # no persistent connection.  ignored.
  end

  def reset_all
    # no persistent connection.  ignored.
  end

  def post(url, req_body, header = {})
    url = URI.parse(url)
    extra = header.dup
    extra['User-Agent'] = @agent if @agent
    res = start(url) { |http|
      http.post(url.request_uri, req_body, extra)
    }
    Response.new(res)
  end

  def get_content(url, header = {})
    url = URI.parse(url)
    extra = header.dup
    extra['User-Agent'] = @agent if @agent
    res = start(url) { |http|
	http.get(url.request_uri, extra)
      }
    res.body
  end

private

  def start(url)
    http = create_connection(url)
    response = nil
    http.start { |worker|
      response, = yield(worker)
      worker.finish
    }
    @debug_dev << response.body if @debug_dev
    response
  end

  def create_connection(url)
    proxy_host = proxy_port = nil
    unless no_proxy?(url)
      proxy_host = @proxy.host
      proxy_port = @proxy.port
    end
    http = Net::HTTP::Proxy(proxy_host, proxy_port).new(url.host, url.port)
    if http.respond_to?(:set_debug_output)
      http.set_debug_output(@debug_dev)
    end
    case url
    when URI::HTTPS
      if SSLEnabled
	http.use_ssl = true
      else
	raise RuntimeError.new("Cannot connect to #{url} (OpenSSL is not installed.)")
      end
    when URI::HTTP
      # OK
    else
      raise RuntimeError.new("Cannot connect to #{url} (Not HTTP.)")
    end
    http
  end

  NO_PROXY_HOSTS = ['localhost']

  def no_proxy?(uri)
    if !@proxy or NO_PROXY_HOSTS.include?(uri.host)
      return true
    end
    if @no_proxy
      @no_proxy.scan(/([^:,]*)(?::(\d+))?/) do |host, port|
  	if /(\A|\.)#{Regexp.quote(host)}\z/i =~ uri.host &&
	    (!port || uri.port == port.to_i)
	  return true
	end
      end
    else
      false
    end
  end

  class SessionManager
    attr_accessor :connect_timeout
    attr_accessor :send_timeout
    attr_accessor :receive_timeout
  end

  class Response
    attr_reader :content
    attr_reader :status
    attr_reader :reason
    attr_reader :contenttype

    def initialize(res)
      @status = res.code.to_i
      @reason = res.message
      @contenttype = res['content-type']
      @content = res.body
    end
  end
end


end
