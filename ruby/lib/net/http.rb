#
# = net/http.rb
#
# Copyright (c) 1999-2003 Yukihiro Matsumoto
# Copyright (c) 1999-2003 Minero Aoki
# 
# Written & maintained by Minero Aoki <aamine@loveruby.net>.
#
# This file is derived from "http-access.rb".
#
# Documented by Minero Aoki; converted to RDoc by William Webber.
# 
# This program is free software. You can re-distribute and/or
# modify this program under the same terms of ruby itself ---
# Ruby Distribution License or GNU General Public License.
#
# See Net::HTTP for an overview and examples. 
# 
# NOTE: You can find Japanese version of this document here:
# http://www.ruby-lang.org/ja/man/?cmd=view;name=net%2Fhttp.rb
# 
#--
# $Id: http.rb,v 1.100.2.7 2004/12/15 18:14:54 aamine Exp $
#++ 

require 'net/protocol'
require 'uri'


module Net # :nodoc:

  # :stopdoc:
  class HTTPBadResponse < StandardError; end
  class HTTPHeaderSyntaxError < StandardError; end
  # :startdoc:

  # == What Is This Library?
  # 
  # This library provides your program functions to access WWW
  # documents via HTTP, Hyper Text Transfer Protocol version 1.1.
  # For details of HTTP, refer [RFC2616]
  # (http://www.ietf.org/rfc/rfc2616.txt).
  # 
  # == Examples
  # 
  # === Getting Document From WWW Server
  # 
  # (formal version)
  # 
  #     require 'net/http'
  #     Net::HTTP.start('www.example.com', 80) { |http|
  #         response = http.get('/index.html')
  #         puts response.body
  #     }
  # 
  # (shorter version)
  # 
  #     require 'net/http'
  #     Net::HTTP.get_print 'www.example.com', '/index.html'
  # 
  #             or
  # 
  #     require 'net/http'
  #     require 'uri'
  #     Net::HTTP.get_print URI.parse('http://www.example.com/index.html')
  # 
  # === Posting Form Data
  # 
  #     require 'net/http'
  #     Net::HTTP.start('some.www.server', 80) { |http|
  #         response = http.post('/cgi-bin/search.rb', 'query=ruby')
  #     }
  # 
  # === Accessing via Proxy
  # 
  # Net::HTTP.Proxy creates http proxy class. It has same
  # methods of Net::HTTP but its instances always connect to
  # proxy, instead of given host.
  # 
  #     require 'net/http'
  # 
  #     proxy_addr = 'your.proxy.host'
  #     proxy_port = 8080
  #             :
  #     Net::HTTP::Proxy(proxy_addr, proxy_port).start('www.example.com') {|http|
  #         # always connect to your.proxy.addr:8080
  #             :
  #     }
  # 
  # Since Net::HTTP.Proxy returns Net::HTTP itself when proxy_addr is nil,
  # there's no need to change code if there's proxy or not.
  # 
  # There are two additional parameters in Net::HTTP.Proxy which allow to
  # specify proxy user name and password:
  # 
  #     Net::HTTP::Proxy(proxy_addr, proxy_port, proxy_user = nil, proxy_pass = nil)
  # 
  # You may use them to work with authorization-enabled proxies:
  # 
  #     require 'net/http'
  #     require 'uri'
  #     
  #     proxy_host = 'your.proxy.host'
  #     proxy_port = 8080
  #     uri = URI.parse(ENV['http_proxy'])
  #     proxy_user, proxy_pass = uri.userinfo.split(/:/) if uri.userinfo
  #     Net::HTTP::Proxy(proxy_host, proxy_port,
  #                      proxy_user, proxy_pass).start('www.example.com') {|http|
  #       # always connect to your.proxy.addr:8080 using specified username and password
  #             :
  #     }
  #
  # Note that net/http never rely on HTTP_PROXY environment variable.
  # If you want to use proxy, set it explicitly.
  # 
  # === Following Redirection
  # 
  #     require 'net/http'
  #     require 'uri'
  # 
  #     def fetch( uri_str, limit = 10 )
  #       # You should choose better exception. 
  #       raise ArgumentError, 'HTTP redirect too deep' if limit == 0
  # 
  #       response = Net::HTTP.get_response(URI.parse(uri_str))
  #       case response
  #       when Net::HTTPSuccess     then response
  #       when Net::HTTPRedirection then fetch(response['location'], limit - 1)
  #       else
  #         response.error!
  #       end
  #     end
  # 
  #     print fetch('http://www.ruby-lang.org')
  # 
  # Net::HTTPSuccess and Net::HTTPRedirection is a HTTPResponse class.
  # All HTTPResponse objects belong to its own response class which
  # indicate HTTP result status. For details of response classes,
  # see section "HTTP Response Classes".
  # 
  # === Basic Authentication
  # 
  #     require 'net/http'
  # 
  #     Net::HTTP.start('www.example.com') {|http|
  #       req = Net::HTTP::Get.new('/secret-page.html')
  #       req.basic_auth 'account', 'password'
  #       response = http.request(req)
  #       print response.body
  #     }
  # 
  # === HTTP Response Classes
  #
  # TODO: write me.
  # 
  # == Switching Net::HTTP versions
  # 
  # You can use net/http.rb 1.1 features (bundled with Ruby 1.6)
  # by calling HTTP.version_1_1. Calling Net::HTTP.version_1_2
  # allows you to use 1.2 features again.
  # 
  #     # example
  #     Net::HTTP.start { |http1| ...(http1 has 1.2 features)... }
  # 
  #     Net::HTTP.version_1_1
  #     Net::HTTP.start { |http2| ...(http2 has 1.1 features)... }
  # 
  #     Net::HTTP.version_1_2
  #     Net::HTTP.start { |http3| ...(http3 has 1.2 features)... }
  # 
  # This function is NOT thread-safe.
  #
  class HTTP < Protocol

    # :stopdoc:
    Revision = %q$Revision: 1.100.2.7 $.split[1]
    HTTPVersion = '1.1'
    @@newimpl = true    # for backward compatability
    # :startdoc:

    # Turns on net/http 1.2 (ruby 1.8) features.
    # Defaults to ON in ruby 1.8.
    #
    # I strongly recommend to call this method always.
    #
    #   require 'net/http'
    #   Net::HTTP.version_1_2
    #
    def HTTP.version_1_2
      @@newimpl = true
    end

    # Turns on net/http 1.1 (ruby 1.6) features.
    # Defaults to OFF in ruby 1.8.
    def HTTP.version_1_1
      @@newimpl = false
    end

    # true if net/http is in version 1.2 mode.
    # Defaults to true.
    def HTTP.version_1_2?
      @@newimpl
    end

    # true if net/http is in version 1.1 compatible mode.
    # Defaults to true.
    def HTTP.version_1_1?
      not @@newimpl
    end

    class << HTTP
      alias is_version_1_1? version_1_1?   #:nodoc:
      alias is_version_1_2? version_1_2?   #:nodoc:
    end

    def HTTP.setimplversion(obj)   #:nodoc:
      f = @@newimpl
      obj.instance_eval { @newimpl = f }
    end
    private_class_method :setimplversion

    #
    # short cut methods
    #

    #
    # Get body from target and output it to +$stdout+.  The
    # target can either be specified as (+uri+), or as
    # (+host+, +path+, +port+ = 80); so: 
    #
    #    Net::HTTP.get_print URI.parse('http://www.example.com/index.html')
    #
    # or:
    #
    #    Net::HTTP.get_print('www.example.com', '/index.html')
    #
    def HTTP.get_print(arg1, arg2 = nil, port = nil)
      if arg2
        addr, path = arg1, arg2
      else
        uri = arg1
        addr = uri.host
        path = uri.request_uri
        port = uri.port
      end
      new(addr, port || HTTP.default_port).start {|http|
        http.get path, nil, $stdout
      }
      nil
    end

    # Send a GET request to the target and return the response
    # as a string.  The target can either be specified as
    # (+uri+), or as (+host+, +path+, +port+ = 80); so:
    # 
    #    print Net::HTTP.get(URI.parse('http://www.example.com/index.html'))
    #
    # or:
    #
    #    print Net::HTTP.get('www.example.com', '/index.html')
    #
    def HTTP.get(arg1, arg2 = nil, arg3 = nil)
      get_response(arg1,arg2,arg3).body
    end

    # Send a GET request to the target and return the response
    # as a Net::HTTPResponse object.  The target can either be specified as
    # (+uri+), or as (+host+, +path+, +port+ = 80); so:
    # 
    #    res = Net::HTTP.get_response(URI.parse('http://www.example.com/index.html'))
    #    print res.body
    #
    # or:
    #
    #    res = Net::HTTP.get_response('www.example.com', '/index.html')
    #    print res.body
    #
    def HTTP.get_response(arg1, arg2 = nil, arg3 = nil)
      if arg2
        get_by_path(arg1, arg2, arg3)
      else
        get_by_uri(arg1)
      end
    end

    def HTTP.get_by_path(addr, path, port = nil)   #:nodoc:
      new(addr, port || HTTP.default_port).start {|http|
        return http.request(Get.new(path))
      }
    end
    private_class_method :get_by_path

    def HTTP.get_by_uri(uri)   #:nodoc:
      # Should we allow this?
      # uri = URI.parse(uri) unless uri.respond_to?(:host)
      new(uri.host, uri.port).start {|http|
        return http.request(Get.new(uri.request_uri))
      }
    end
    private_class_method :get_by_uri

    #
    # HTTP session management
    #

    # The default port to use for HTTP requests; defaults to 80.
    def HTTP.default_port
      80
    end

    def HTTP.socket_type   #:nodoc: obsolete
      InternetMessageIO
    end

    class << HTTP
      # creates a new Net::HTTP object and opens its TCP connection and 
      # HTTP session.  If the optional block is given, the newly 
      # created Net::HTTP object is passed to it and closed when the 
      # block finishes.  In this case, the return value of this method
      # is the return value of the block.  If no block is given, the
      # return value of this method is the newly created Net::HTTP object
      # itself, and the caller is responsible for closing it upon completion.
      def start(address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil, &block) # :yield: +http+
        new(address, port, p_addr, p_port, p_user, p_pass).start(&block)
      end

      alias newobj new

      # Creates a new Net::HTTP object.
      # If +proxy_addr+ is given, creates an Net::HTTP object with proxy support.
      # This method does not open the TCP connection.
      def new(address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil)
        obj = Proxy(p_addr, p_port, p_user, p_pass).newobj(address, port)
        setimplversion obj
        obj
      end
    end

    # Creates a new Net::HTTP object for the specified +address+.
    # This method does not open the TCP connection.
    def initialize(address, port = nil)
      @address = address
      @port    = (port || HTTP.default_port)

      @curr_http_version = HTTPVersion
      @seems_1_0_server = false
      @close_on_empty_response = false
      @socket  = nil
      @started = false

      @open_timeout = 30
      @read_timeout = 60

      @debug_output = nil
    end

    def inspect
      "#<#{self.class} #{@address}:#{@port} open=#{started?}>"
    end

    # *WARNING* This method causes serious security hole.
    # Never use this method in production code.
    #
    # Set an output stream for debugging.
    #
    #   http = Net::HTTP.new
    #   http.set_debug_output $stderr
    #   http.start { .... }
    #
    def set_debug_output(output)
      warn 'Net::HTTP#set_debug_output called after HTTP started' if started?
      @debug_output = output
    end

    # The host name to connect to.
    attr_reader :address

    # The port number to connect to.
    attr_reader :port

    # Seconds to wait until connection is opened.
    # If the HTTP object cannot open a connection in this many seconds,
    # it raises a TimeoutError exception.
    attr_accessor :open_timeout

    # Seconds to wait until reading one block (by one read(2) call).
    # If the HTTP object cannot open a connection in this many seconds,
    # it raises a TimeoutError exception.
    attr_reader :read_timeout

    # Setter for the read_timeout attribute.
    def read_timeout=(sec)
      @socket.read_timeout = sec if @socket
      @read_timeout = sec
    end

    # returns true if the HTTP session is started.
    def started?
      @started
    end

    alias active? started?   #:nodoc: obsolete

    attr_accessor :close_on_empty_response

    # Opens TCP connection and HTTP session.
    # 
    # When this method is called with block, gives a HTTP object
    # to the block and closes the TCP connection / HTTP session
    # after the block executed.
    #
    # When called with a block, returns the return value of the
    # block; otherwise, returns self.
    #
    def start  # :yield: http
      raise IOError, 'HTTP session already opened' if @started
      if block_given?
        begin
          do_start
          return yield(self)
        ensure
          do_finish
        end
      end
      do_start
      self
    end

    def do_start
      @socket = self.class.socket_type.open(conn_address(), conn_port(),
                                            @open_timeout, @read_timeout,
                                            @debug_output)
      on_connect
      @started = true
    end
    private :do_start

    def on_connect
    end
    private :on_connect

    # Finishes HTTP session and closes TCP connection.
    # Raises IOError if not started.
    def finish
      raise IOError, 'HTTP session not yet started' unless started?
      do_finish
    end

    def do_finish
      @started = false
      @socket.close if @socket and not @socket.closed?
      @socket = nil
    end
    private :do_finish

    #
    # proxy
    #

    public

    # no proxy
    @is_proxy_class = false
    @proxy_addr = nil
    @proxy_port = nil
    @proxy_user = nil
    @proxy_pass = nil

    # Creates an HTTP proxy class.
    # Arguments are address/port of proxy host and username/password
    # if authorization on proxy server is required.
    # You can replace the HTTP class with created proxy class.
    # 
    # If ADDRESS is nil, this method returns self (Net::HTTP).
    # 
    #     # Example
    #     proxy_class = Net::HTTP::Proxy('proxy.example.com', 8080)
    #                     :
    #     proxy_class.start('www.ruby-lang.org') {|http|
    #       # connecting proxy.foo.org:8080
    #                     :
    #     }
    # 
    def HTTP.Proxy(p_addr, p_port = nil, p_user = nil, p_pass = nil)
      return self unless p_addr
      delta = ProxyDelta
      proxyclass = Class.new(self)
      proxyclass.module_eval {
        include delta
        # with proxy
        @is_proxy_class = true
        @proxy_address = p_addr
        @proxy_port    = p_port || default_port()
        @proxy_user    = p_user
        @proxy_pass    = p_pass
      }
      proxyclass
    end

    class << HTTP
      # returns true if self is a class which was created by HTTP::Proxy.
      def proxy_class?
        @is_proxy_class
      end

      attr_reader :proxy_address
      attr_reader :proxy_port
      attr_reader :proxy_user
      attr_reader :proxy_pass
    end

    # True if self is a HTTP proxy class
    def proxy?
      self.class.proxy_class?
    end

    # Address of proxy host. If self does not use a proxy, nil.
    def proxy_address
      self.class.proxy_address
    end

    # Port number of proxy host. If self does not use a proxy, nil.
    def proxy_port
      self.class.proxy_port
    end

    # User name for accessing proxy. If self does not use a proxy, nil.
    def proxy_user
      self.class.proxy_user
    end

    # User password for accessing proxy. If self does not use a proxy, nil.
    def proxy_pass
      self.class.proxy_pass
    end

    alias proxyaddr proxy_address   #:nodoc: obsolete
    alias proxyport proxy_port      #:nodoc: obsolete

    private

    # without proxy

    def conn_address
      address
    end

    def conn_port
      port
    end

    def edit_path(path)
      path
    end

    module ProxyDelta   #:nodoc: internal use only
      private

      def conn_address
        proxy_address()
      end

      def conn_port
        proxy_port()
      end

      def edit_path(path)
        'http://' + addr_port() + path
      end
    end

    #
    # HTTP operations
    #

    public

    # Gets data from +path+ on the connected-to host.
    # +header+ must be a Hash like { 'Accept' => '*/*', ... }.
    #
    # In version 1.1 (ruby 1.6), this method returns a pair of objects,
    # a Net::HTTPResponse object and the entity body string.
    # In version 1.2 (ruby 1.8), this method returns a Net::HTTPResponse
    # object.
    #
    # If called with a block, yields each fragment of the
    # entity body in turn as a string as it is read from
    # the socket.  Note that in this case, the returned response
    # object will *not* contain a (meaningful) body.
    #
    # +dest+ argument is obsolete.
    # It still works but you must not use it.
    #
    # In version 1.1, this method might raise an exception for 
    # 3xx (redirect). In this case you can get a HTTPResponse object
    # by "anException.response".
    #
    # In version 1.2, this method never raises exception.
    #
    #     # version 1.1 (bundled with Ruby 1.6)
    #     response, body = http.get('/index.html')
    #
    #     # version 1.2 (bundled with Ruby 1.8 or later)
    #     response = http.get('/index.html')
    #     
    #     # using block
    #     File.open('result.txt', 'w') {|f|
    #       http.get('/~foo/') do |str|
    #         f.write str
    #       end
    #     }
    #
    def get(path, initheader = nil, dest = nil, &block) # :yield: +body_segment+
      res = nil
      request(Get.new(path, initheader)) {|r|
        r.read_body dest, &block
        res = r
      }
      unless @newimpl
        res.value
        return res, res.body
      end

      res
    end

    # Gets only the header from +path+ on the connected-to host.
    # +header+ is a Hash like { 'Accept' => '*/*', ... }.
    # 
    # This method returns a Net::HTTPResponse object.
    # 
    # In version 1.1, this method might raise an exception for 
    # 3xx (redirect). On the case you can get a HTTPResponse object
    # by "anException.response".
    # In version 1.2, this method never raises an exception.
    # 
    #     response = nil
    #     Net::HTTP.start('some.www.server', 80) {|http|
    #       response = http.head('/index.html')
    #     }
    #     p response['content-type']
    #
    def head(path, initheader = nil) 
      res = request(Head.new(path, initheader))
      res.value unless @newimpl
      res
    end

    # Posts +data+ (must be a String) to +path+. +header+ must be a Hash
    # like { 'Accept' => '*/*', ... }.
    # 
    # In version 1.1 (ruby 1.6), this method returns a pair of objects, a
    # Net::HTTPResponse object and an entity body string.
    # In version 1.2 (ruby 1.8), this method returns a Net::HTTPResponse object.
    # 
    # If called with a block, yields each fragment of the
    # entity body in turn as a string as it are read from
    # the socket.  Note that in this case, the returned response
    # object will *not* contain a (meaningful) body.
    #
    # +dest+ is an alternative method of collecting the body.  It
    # must be an object responding to the "<<" operator (such as
    # a String or an Array).  Each fragment of the entity body
    # will be "<<"-ed in turn onto +dest+ if provided, and it will
    # also become the body of the returned response object.
    #
    # You must *not* provide both +dest+ and a block; doing so
    # will result in an ArgumentError.
    # 
    # In version 1.1, this method might raise an exception for 
    # 3xx (redirect). In this case you can get an HTTPResponse object
    # by "anException.response".
    # In version 1.2, this method never raises exception.
    # 
    #     # version 1.1
    #     response, body = http.post('/cgi-bin/search.rb', 'query=foo')
    # 
    #     # version 1.2
    #     response = http.post('/cgi-bin/search.rb', 'query=foo')
    # 
    #     # using block
    #     File.open('result.txt', 'w') {|f|
    #       http.post('/cgi-bin/search.rb', 'query=foo') do |str|
    #         f.write str
    #       end
    #     }
    #
    def post(path, data, initheader = nil, dest = nil, &block) # :yield: +body_segment+
      res = nil
      request(Post.new(path, initheader), data) {|r|
        r.read_body dest, &block
        res = r
      }
      unless @newimpl
        res.value
        return res, res.body
      end

      res
    end

    def put(path, data, initheader = nil)   #:nodoc:
      res = request(Put.new(path, initheader), data)
      res.value unless @newimpl
      res
    end

    # Sends a GET request to the +path+ and gets a response,
    # as an HTTPResponse object.
    # 
    # When called with a block, yields an HTTPResponse object.
    # The body of this response will not have been read yet;
    # the caller can process it using HTTPResponse#read_body,
    # if desired.
    #
    # Returns the response.
    # 
    # This method never raises Net::* exceptions.
    # 
    #     response = http.request_get('/index.html')
    #     # The entity body is already read here.
    #     p response['content-type']
    #     puts response.body
    # 
    #     # using block
    #     http.request_get('/index.html') {|response|
    #       p response['content-type']
    #       response.read_body do |str|   # read body now
    #         print str
    #       end
    #     }
    #
    def request_get(path, initheader = nil, &block) # :yield: +response+
      request(Get.new(path, initheader), &block)
    end

    # Sends a HEAD request to the +path+ and gets a response,
    # as an HTTPResponse object.
    #
    # Returns the response.
    # 
    # This method never raises Net::* exceptions.
    # 
    #     response = http.request_head('/index.html')
    #     p response['content-type']
    #
    def request_head(path, initheader = nil, &block)
      request(Head.new(path, initheader), &block)
    end

    # Sends a POST request to the +path+ and gets a response,
    # as an HTTPResponse object.
    # 
    # When called with a block, yields an HTTPResponse object.
    # The body of this response will not have been read yet;
    # the caller can process it using HTTPResponse#read_body,
    # if desired.
    #
    # Returns the response.
    # 
    # This method never raises Net::* exceptions.
    # 
    #     # example
    #     response = http.request_post('/cgi-bin/nice.rb', 'datadatadata...')
    #     p response.status
    #     puts response.body          # body is already read
    # 
    #     # using block
    #     http.request_post('/cgi-bin/nice.rb', 'datadatadata...') {|response|
    #       p response.status
    #       p response['content-type']
    #       response.read_body do |str|   # read body now
    #         print str
    #       end
    #     }
    #
    def request_post(path, data, initheader = nil, &block) # :yield: +response+
      request Post.new(path, initheader), data, &block
    end

    def request_put(path, data, initheader = nil, &block)   #:nodoc:
      request Put.new(path, initheader), data, &block
    end

    alias get2   request_get    #:nodoc: obsolete
    alias head2  request_head   #:nodoc: obsolete
    alias post2  request_post   #:nodoc: obsolete
    alias put2   request_put    #:nodoc: obsolete


    # Sends an HTTP request to the HTTP server.
    # This method also sends DATA string if DATA is given.
    #
    # Returns a HTTPResponse object.
    # 
    # This method never raises Net::* exceptions.
    #
    #    response = http.send_request('GET', '/index.html')
    #    puts response.body
    #
    def send_request(name, path, data = nil, header = nil)
      r = HTTPGenericRequest.new(name,(data ? true : false),true,path,header)
      request r, data
    end

    # Sends an HTTPRequest object REQUEST to the HTTP server.
    # This method also sends DATA string if REQUEST is a post/put request.
    # Giving DATA for get/head request causes ArgumentError.
    # 
    # When called with a block, yields an HTTPResponse object.
    # The body of this response will not have been read yet;
    # the caller can process it using HTTPResponse#read_body,
    # if desired.
    #
    # Returns a HTTPResponse object.
    # 
    # This method never raises Net::* exceptions.
    #
    def request(req, body = nil, &block)  # :yield: +response+
      unless started?
        start {
          req['connection'] ||= 'close'
          return request(req, body, &block)
        }
      end
      if proxy_user()
        req.proxy_basic_auth proxy_user(), proxy_pass()
      end

      begin_transport req
        req.exec @socket, @curr_http_version, edit_path(req.path), body
        begin
          res = HTTPResponse.read_new(@socket)
        end while HTTPContinue === res
        res.reading_body(@socket, req.response_body_permitted?) {
          yield res if block_given?
        }
      end_transport req, res

      res
    end

    private

    def begin_transport(req)
      if @socket.closed?
        @socket.reopen @open_timeout
        on_connect
      end
      if @seems_1_0_server
        req['connection'] ||= 'close'
      end
      if not req.response_body_permitted? and @close_on_empty_response
        req['connection'] ||= 'close'
      end
      req['host'] ||= addr_port()
    end

    def end_transport(req, res)
      @curr_http_version = res.http_version
      if not res.body and @close_on_empty_response
        D 'Conn close'
        @socket.close
      elsif keep_alive?(req, res)
        D 'Conn keep-alive'
        if @socket.closed?
          D 'Conn (but seems 1.0 server)'
          @seems_1_0_server = true
        end
      else
        D 'Conn close'
        @socket.close
      end
    end

    def keep_alive?(req, res)
      return false if /close/i =~ req['connection'].to_s
      return false if @seems_1_0_server
      return true  if /keep-alive/i =~ res['connection'].to_s
      return false if /close/i      =~ res['connection'].to_s
      return true  if /keep-alive/i =~ res['proxy-connection'].to_s
      return false if /close/i      =~ res['proxy-connection'].to_s
      (@curr_http_version == '1.1')
    end

    #
    # utils
    #

    private

    def addr_port
      address + (port == HTTP.default_port ? '' : ":#{port}")
    end

    def D(msg)
      return unless @debug_output
      @debug_output << msg
      @debug_output << "\n"
    end

  end

  HTTPSession = HTTP

  #
  # Header module.
  #
  # Provides access to @header in the mixed-into class as a hash-like
  # object, except with case-insensitive keys.  Also provides
  # methods for accessing commonly-used header values in a more
  # convenient format.
  #
  module HTTPHeader

    def size   #:nodoc: obsolete
      @header.size
    end

    alias length size   #:nodoc: obsolete

    # Returns the header field corresponding to the case-insensitive key.
    # For example, a key of "Content-Type" might return "text/html"
    def [](key)
      @header[key.downcase]
    end

    # Sets the header field corresponding to the case-insensitive key.
    def []=(key, val)
      @header[key.downcase] = val
    end

    # Returns the header field corresponding to the case-insensitive key.
    # Returns the default value +args+, or the result of the block, or nil,
    # if there's no header field named key.  See Hash#fetch
    def fetch(key, *args, &block)   #:yield: +key+
      @header.fetch(key.downcase, *args, &block)
    end

    # Iterates for each header names and values.
    def each_header(&block)   #:yield: +key+, +value+
      @header.each(&block)
    end

    alias each each_header

    # Iterates for each header names.
    def each_key(&block)   #:yield: +key+
      @header.each_key(&block)
    end

    # Iterates for each header values.
    def each_value(&block)   #:yield: +value+
      @header.each_value(&block)
    end

    # Removes a header field.
    def delete(key)
      @header.delete(key.downcase)
    end

    # true if +key+ header exists.
    def key?(key)
      @header.key?(key.downcase)
    end

    # Returns a Hash consist of header names and values.
    def to_hash
      @header.dup
    end

    # As for #each_header, except the keys are provided in capitalized form.
    def canonical_each
      @header.each do |k,v|
        yield canonical(k), v
      end
    end

    def canonical( k )
      k.split(/-/).map {|i| i.capitalize }.join('-')
    end
    private :canonical

    # Returns a Range object which represents Range: header field,
    # or +nil+ if there is no such header.
    def range
      s = @header['range'] or return nil
      s.split(/,/).map {|spec|
        m = /bytes\s*=\s*(\d+)?\s*-\s*(\d+)?/i.match(spec) or
                raise HTTPHeaderSyntaxError, "wrong Range: #{spec}"
        d1 = m[1].to_i
        d2 = m[2].to_i
        if    m[1] and m[2] then  d1..d2
        elsif m[1]          then  d1..-1
        elsif          m[2] then -d2..-1
        else
          raise HTTPHeaderSyntaxError, 'range is not specified'
        end
      }
    end

    # Set Range: header from Range (arg r) or beginning index and
    # length from it (arg i&len).
    def range=(r, fin = nil)
      r = (r ... r + fin) if fin
      case r
      when Numeric
        s = r > 0 ? "0-#{r - 1}" : "-#{-r}"
      when Range
        first = r.first
        last = r.last
        if r.exclude_end?
          last -= 1
        end

        if last == -1
          s = first > 0 ? "#{first}-" : "-#{-first}"
        else
          first >= 0 or raise HTTPHeaderSyntaxError, 'range.first is negative' 
          last > 0  or raise HTTPHeaderSyntaxError, 'range.last is negative' 
          first < last or raise HTTPHeaderSyntaxError, 'must be .first < .last'
          s = "#{first}-#{last}"
        end
      else
        raise TypeError, 'Range/Integer is required'
      end

      @header['range'] = "bytes=#{s}"
      r
    end

    alias set_range range=

    # Returns an Integer object which represents the Content-Length: header field
    # or +nil+ if that field is not provided.
    def content_length
      s = @header['content-length'] or return nil
      m = /\d+/.match(s) or
              raise HTTPHeaderSyntaxError, 'wrong Content-Length format'
      m[0].to_i
    end

    # Returns "true" if the "transfer-encoding" header is present and
    # set to "chunked".  This is an HTTP/1.1 feature, allowing the 
    # the content to be sent in "chunks" without at the outset
    # stating the entire content length.
    def chunked?
      s = @header['transfer-encoding']
      (s and /(?:\A|[^\-\w])chunked(?:[^\-\w]|\z)/i === s) ? true : false
    end

    # Returns a Range object which represents Content-Range: header field.
    # This indicates, for a partial entity body, where this fragment
    # fits inside the full entity body, as range of byte offsets.
    def content_range
      s = @header['content-range'] or return nil
      m = %r<bytes\s+(\d+)-(\d+)/(?:\d+|\*)>i.match(s) or
              raise HTTPHeaderSyntaxError, 'wrong Content-Range format'
      m[1].to_i .. m[2].to_i + 1
    end

    # The length of the range represented in Range: header.
    def range_length
      r = self.content_range
      r and (r.end - r.begin)
    end

    # Set the Authorization: header for "Basic" authorization.
    def basic_auth(account, password)
      @header['authorization'] = basic_encode(account, password)
    end

    # Set Proxy-Authorization: header for "Basic" authorization.
    def proxy_basic_auth(account, password)
      @header['proxy-authorization'] = basic_encode(account, password)
    end

    def basic_encode(account, password)
      'Basic ' + ["#{account}:#{password}"].pack('m').delete("\r\n")
    end
    private :basic_encode

  end

  #
  # Parent of HTTPRequest class.  Do not use this directly; use
  # a subclass of HTTPRequest.
  #
  # Mixes in the HTTPHeader module.
  #
  class HTTPGenericRequest

    include HTTPHeader

    def initialize(m, reqbody, resbody, path, initheader = nil)
      @method = m
      @request_has_body = reqbody
      @response_has_body = resbody
      @path = path

      @header = {}
      return unless initheader
      initheader.each do |k,v|
        key = k.downcase
        $stderr.puts "net/http: warning: duplicated HTTP header: #{k}" if @header.key?(key) and $VERBOSE
        @header[key] = v.strip
      end
      @header['accept'] ||= '*/*'
    end

    attr_reader :method
    attr_reader :path

    def inspect
      "\#<#{self.class} #{@method}>"
    end

    def request_body_permitted?
      @request_has_body
    end

    def response_body_permitted?
      @response_has_body
    end

    alias body_exist? response_body_permitted?

    #
    # write
    #

    def exec(sock, ver, path, body)   #:nodoc: internal use only
      if body
        check_body_permitted
        send_request_with_body sock, ver, path, body
      else
        request sock, ver, path
      end
    end

    private

    def check_body_permitted
      request_body_permitted? or
          raise ArgumentError, 'HTTP request body is not permitted'
    end

    def send_request_with_body( sock, ver, path, body )
      @header['content-length'] = body.length.to_s
      @header.delete 'transfer-encoding'

      unless @header['content-type']
        $stderr.puts 'net/http: warning: Content-Type did not set; using application/x-www-form-urlencoded' if $VERBOSE
        @header['content-type'] = 'application/x-www-form-urlencoded'
      end

      request sock, ver, path
      sock.write body
    end

    def request(sock, ver, path)
      buf = "#{@method} #{path} HTTP/#{ver}\r\n"
      canonical_each do |k,v|
        buf << k + ': ' + v + "\r\n"
      end
      buf << "\r\n"
      sock.write buf
    end
  
  end


  # 
  # HTTP request class. This class wraps request header and entity path.
  # You *must* use its subclass, Net::HTTP::Get, Post, Head.
  # 
  class HTTPRequest < HTTPGenericRequest

    # Creates HTTP request object.
    def initialize(path, initheader = nil)
      super self.class::METHOD,
            self.class::REQUEST_HAS_BODY,
            self.class::RESPONSE_HAS_BODY,
            path, initheader
    end
  end


  class HTTP

    class Get < HTTPRequest
      METHOD = 'GET'
      REQUEST_HAS_BODY  = false
      RESPONSE_HAS_BODY = true
    end

    class Head < HTTPRequest
      METHOD = 'HEAD'
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
    end

    class Post < HTTPRequest
      METHOD = 'POST'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end

    class Put < HTTPRequest
      METHOD = 'PUT'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end

  end


  ###
  ### Response
  ###

  # HTTP exception class.
  # You must use its subclasses.
  module HTTPExceptions
    def initialize(msg, res)   #:nodoc:
      super msg
      @response = res
    end
    attr_reader :response
    alias data response    #:nodoc: obsolete
  end
  class HTTPError < ProtocolError
    include HTTPExceptions
  end
  class HTTPRetriableError < ProtoRetriableError
    include HTTPExceptions
  end
  class HTTPServerException < ProtoServerError
    # We cannot use the name "HTTPServerError", it is the name of the response.
    include HTTPExceptions
  end
  class HTTPFatalError < ProtoFatalError
    include HTTPExceptions
  end


  # HTTP response class. This class wraps response header and entity.
  # Mixes in the HTTPHeader module, which provides access to response
  # header values both via hash-like methods and individual readers.
  # Note that each possible HTTP response code defines its own 
  # HTTPResponse subclass.  These are listed below.
  # All classes are
  # defined under the Net module. Indentation indicates inheritance.
  # 
  #   xxx        HTTPResponse
  # 
  #     1xx        HTTPInformation
  #       100        HTTPContinue    
  #       101        HTTPSwitchProtocol
  # 
  #     2xx        HTTPSuccess
  #       200        HTTPOK
  #       201        HTTPCreated
  #       202        HTTPAccepted
  #       203        HTTPNonAuthoritativeInformation
  #       204        HTTPNoContent
  #       205        HTTPResetContent
  #       206        HTTPPartialContent
  # 
  #     3xx        HTTPRedirection
  #       300        HTTPMultipleChoice
  #       301        HTTPMovedPermanently
  #       302        HTTPFound
  #       303        HTTPSeeOther
  #       304        HTTPNotModified
  #       305        HTTPUseProxy
  #       307        HTTPTemporaryRedirect
  # 
  #     4xx        HTTPClientError
  #       400        HTTPBadRequest
  #       401        HTTPUnauthorized
  #       402        HTTPPaymentRequired
  #       403        HTTPForbidden
  #       404        HTTPNotFound
  #       405        HTTPMethodNotAllowed
  #       406        HTTPNotAcceptable
  #       407        HTTPProxyAuthenticationRequired
  #       408        HTTPRequestTimeOut
  #       409        HTTPConflict
  #       410        HTTPGone
  #       411        HTTPLengthRequired
  #       412        HTTPPreconditionFailed
  #       413        HTTPRequestEntityTooLarge
  #       414        HTTPRequestURITooLong
  #       415        HTTPUnsupportedMediaType
  #       416        HTTPRequestedRangeNotSatisfiable
  #       417        HTTPExpectationFailed
  # 
  #     5xx        HTTPServerError
  #       500        HTTPInternalServerError
  #       501        HTTPNotImplemented
  #       502        HTTPBadGateway
  #       503        HTTPServiceUnavailable
  #       504        HTTPGatewayTimeOut
  #       505        HTTPVersionNotSupported
  # 
  #     xxx        HTTPUnknownResponse
  #
  class HTTPResponse
    # true if the response has body.
    def HTTPResponse.body_permitted?
      self::HAS_BODY
    end

    def HTTPResponse.exception_type   # :nodoc: internal use only
      self::EXCEPTION_TYPE
    end
  end   # redefined after

  # :stopdoc:

  class HTTPUnknownResponse < HTTPResponse
    HAS_BODY = true
    EXCEPTION_TYPE = HTTPError
  end
  class HTTPInformation < HTTPResponse           # 1xx
    HAS_BODY = false
    EXCEPTION_TYPE = HTTPError
  end
  class HTTPSuccess < HTTPResponse               # 2xx
    HAS_BODY = true
    EXCEPTION_TYPE = HTTPError
  end
  class HTTPRedirection < HTTPResponse           # 3xx
    HAS_BODY = true
    EXCEPTION_TYPE = HTTPRetriableError
  end
  class HTTPClientError < HTTPResponse           # 4xx
    HAS_BODY = true
    EXCEPTION_TYPE = HTTPServerException   # for backward compatibility
  end
  class HTTPServerError < HTTPResponse           # 5xx
    HAS_BODY = true
    EXCEPTION_TYPE = HTTPFatalError    # for backward compatibility
  end

  class HTTPContinue < HTTPInformation           # 100
    HAS_BODY = false
  end
  class HTTPSwitchProtocol < HTTPInformation     # 101
    HAS_BODY = false
  end

  class HTTPOK < HTTPSuccess                            # 200
    HAS_BODY = true
  end
  class HTTPCreated < HTTPSuccess                       # 201
    HAS_BODY = true
  end
  class HTTPAccepted < HTTPSuccess                      # 202
    HAS_BODY = true
  end
  class HTTPNonAuthoritativeInformation < HTTPSuccess   # 203
    HAS_BODY = true
  end
  class HTTPNoContent < HTTPSuccess                     # 204
    HAS_BODY = false
  end
  class HTTPResetContent < HTTPSuccess                  # 205
    HAS_BODY = false
  end
  class HTTPPartialContent < HTTPSuccess                # 206
    HAS_BODY = true
  end

  class HTTPMultipleChoice < HTTPRedirection     # 300
    HAS_BODY = true
  end
  class HTTPMovedPermanently < HTTPRedirection   # 301
    HAS_BODY = true
  end
  class HTTPFound < HTTPRedirection              # 302
    HAS_BODY = true
  end
  HTTPMovedTemporarily = HTTPFound
  class HTTPSeeOther < HTTPRedirection           # 303
    HAS_BODY = true
  end
  class HTTPNotModified < HTTPRedirection        # 304
    HAS_BODY = false
  end
  class HTTPUseProxy < HTTPRedirection           # 305
    HAS_BODY = false
  end
  # 306 unused
  class HTTPTemporaryRedirect < HTTPRedirection  # 307
    HAS_BODY = true
  end

  class HTTPBadRequest < HTTPClientError                    # 400
    HAS_BODY = true
  end
  class HTTPUnauthorized < HTTPClientError                  # 401
    HAS_BODY = true
  end
  class HTTPPaymentRequired < HTTPClientError               # 402
    HAS_BODY = true
  end
  class HTTPForbidden < HTTPClientError                     # 403
    HAS_BODY = true
  end
  class HTTPNotFound < HTTPClientError                      # 404
    HAS_BODY = true
  end
  class HTTPMethodNotAllowed < HTTPClientError              # 405
    HAS_BODY = true
  end
  class HTTPNotAcceptable < HTTPClientError                 # 406
    HAS_BODY = true
  end
  class HTTPProxyAuthenticationRequired < HTTPClientError   # 407
    HAS_BODY = true
  end
  class HTTPRequestTimeOut < HTTPClientError                # 408
    HAS_BODY = true
  end
  class HTTPConflict < HTTPClientError                      # 409
    HAS_BODY = true
  end
  class HTTPGone < HTTPClientError                          # 410
    HAS_BODY = true
  end
  class HTTPLengthRequired < HTTPClientError                # 411
    HAS_BODY = true
  end
  class HTTPPreconditionFailed < HTTPClientError            # 412
    HAS_BODY = true
  end
  class HTTPRequestEntityTooLarge < HTTPClientError         # 413
    HAS_BODY = true
  end
  class HTTPRequestURITooLong < HTTPClientError             # 414
    HAS_BODY = true
  end
  HTTPRequestURITooLarge = HTTPRequestURITooLong
  class HTTPUnsupportedMediaType < HTTPClientError          # 415
    HAS_BODY = true
  end
  class HTTPRequestedRangeNotSatisfiable < HTTPClientError  # 416
    HAS_BODY = true
  end
  class HTTPExpectationFailed < HTTPClientError             # 417
    HAS_BODY = true
  end

  class HTTPInternalServerError < HTTPServerError   # 500
    HAS_BODY = true
  end
  class HTTPNotImplemented < HTTPServerError        # 501
    HAS_BODY = true
  end
  class HTTPBadGateway < HTTPServerError            # 502
    HAS_BODY = true
  end
  class HTTPServiceUnavailable < HTTPServerError    # 503
    HAS_BODY = true
  end
  class HTTPGatewayTimeOut < HTTPServerError        # 504
    HAS_BODY = true
  end
  class HTTPVersionNotSupported < HTTPServerError   # 505
    HAS_BODY = true
  end

  # :startdoc:


  class HTTPResponse   # redefine

    CODE_CLASS_TO_OBJ = {
      '1' => HTTPInformation,
      '2' => HTTPSuccess,
      '3' => HTTPRedirection,
      '4' => HTTPClientError,
      '5' => HTTPServerError
    }
    CODE_TO_OBJ = {
      '100' => HTTPContinue,
      '101' => HTTPSwitchProtocol,

      '200' => HTTPOK,
      '201' => HTTPCreated,
      '202' => HTTPAccepted,
      '203' => HTTPNonAuthoritativeInformation,
      '204' => HTTPNoContent,
      '205' => HTTPResetContent,
      '206' => HTTPPartialContent,

      '300' => HTTPMultipleChoice,
      '301' => HTTPMovedPermanently,
      '302' => HTTPFound,
      '303' => HTTPSeeOther,
      '304' => HTTPNotModified,
      '305' => HTTPUseProxy,
      '307' => HTTPTemporaryRedirect,

      '400' => HTTPBadRequest,
      '401' => HTTPUnauthorized,
      '402' => HTTPPaymentRequired,
      '403' => HTTPForbidden,
      '404' => HTTPNotFound,
      '405' => HTTPMethodNotAllowed,
      '406' => HTTPNotAcceptable,
      '407' => HTTPProxyAuthenticationRequired,
      '408' => HTTPRequestTimeOut,
      '409' => HTTPConflict,
      '410' => HTTPGone,
      '411' => HTTPLengthRequired,
      '412' => HTTPPreconditionFailed,
      '413' => HTTPRequestEntityTooLarge,
      '414' => HTTPRequestURITooLong,
      '415' => HTTPUnsupportedMediaType,
      '416' => HTTPRequestedRangeNotSatisfiable,
      '417' => HTTPExpectationFailed,

      '501' => HTTPInternalServerError,
      '501' => HTTPNotImplemented,
      '502' => HTTPBadGateway,
      '503' => HTTPServiceUnavailable,
      '504' => HTTPGatewayTimeOut,
      '505' => HTTPVersionNotSupported
    }


    class << self

      def read_new(sock)   #:nodoc: internal use only
        httpv, code, msg = read_status_line(sock)
        res = response_class(code).new(httpv, code, msg)
        each_response_header(sock) do |k,v|
          if res.key?(k)
            res[k] << ', ' << v
          else
            res[k] = v
          end
        end

        res
      end

      private

      def read_status_line(sock)
        str = sock.readline
        m = /\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)\s*(.*)\z/in.match(str) or
                raise HTTPBadResponse, "wrong status line: #{str.dump}"
        m.to_a[1,3]
      end

      def response_class(code)
        CODE_TO_OBJ[code] or
        CODE_CLASS_TO_OBJ[code[0,1]] or
        HTTPUnknownResponse
      end

      def each_response_header(sock)
        while true
          line = sock.readuntil("\n", true).sub(/\s+\z/, '')
          break if line.empty?
          m = /\A([^:]+):\s*/.match(line) or
              raise HTTPBadResponse, 'wrong header line format'
          yield m[1], m.post_match
        end
      end

    end

    # next is to fix bug in RDoc, where the private inside class << self
    # spills out.
    public 

    include HTTPHeader

    def initialize(httpv, code, msg)   #:nodoc: internal use only
      @http_version = httpv
      @code         = code
      @message      = msg

      @header = {}
      @body = nil
      @read = false
    end

    # The HTTP version supported by the server.
    attr_reader :http_version

    # HTTP result code string. For example, '302'.  You can also
    # determine the response type by which response subclass the
    # response object is an instance of.
    attr_reader :code

    # HTTP result message. For example, 'Not Found'.
    attr_reader :message
    alias msg message   # :nodoc: obsolete

    def inspect
      "#<#{self.class} #{@code} readbody=#{@read}>"
    end

    # For backward compatibility.
    # To allow Net::HTTP 1.1 style assignment
    # e.g.
    #    response, body = Net::HTTP.get(....)
    # 
    def to_ary
      warn "net/http.rb: warning: Net::HTTP v1.1 style assignment found at #{caller(1)[0]}; use `response = http.get(...)' instead." if $VERBOSE
      [self, body()]
    end

    #
    # response <-> exception relationship
    #

    def code_type   #:nodoc:
      self.class
    end

    def error!   #:nodoc:
      raise error_type().new(@code + ' ' + @message.dump, self)
    end

    def error_type   #:nodoc:
      self.class::EXCEPTION_TYPE
    end

    # Raises HTTP error if the response is not 2xx.
    def value
      error! unless HTTPSuccess === self
    end

    #
    # header (for backward compatibility only; DO NOT USE)
    #

    def response   #:nodoc:
      self
    end

    alias header response        #:nodoc:
    alias read_header response   #:nodoc:

    #
    # body
    #

    def reading_body(sock, reqmethodallowbody)  #:nodoc: internal use only
      @socket = sock
      @body_exist = reqmethodallowbody && self.class.body_permitted?
      begin
        yield
        self.body   # ensure to read body
      ensure
        @socket = nil
      end
    end

    # Gets entity body.  If the block given, yields it to +block+.
    # The body is provided in fragments, as it is read in from the socket.
    #
    # Calling this method a second or subsequent time will return the
    # already read string.
    #
    #   http.request_get('/index.html') {|res|
    #     puts res.read_body
    #   }
    #
    #   http.request_get('/index.html') {|res|
    #     p res.read_body.object_id   # 538149362
    #     p res.read_body.object_id   # 538149362
    #   }
    #
    #   # using iterator
    #   http.request_get('/index.html') {|res|
    #     res.read_body do |segment|
    #       print segment
    #     end
    #   }
    #
    def read_body(dest = nil, &block)
      if @read
        raise IOError, "#{self.class}\#read_body called twice" if dest or block
        return @body
      end
      to = procdest(dest, block)
      stream_check
      if @body_exist
        read_body_0 to
        @body = to
      else
        @body = nil
      end
      @read = true

      @body
    end

    # Returns the entity body.
    #
    # Calling this method a second or subsequent time will return the
    # already read string.
    #
    #   http.request_get('/index.html') {|res|
    #     puts res.body
    #   }
    #
    #   http.request_get('/index.html') {|res|
    #     p res.body.object_id   # 538149362
    #     p res.body.object_id   # 538149362
    #   }
    #
    def body
      read_body()
    end

    alias entity body   #:nodoc: obsolete

    private

    def read_body_0(dest)
      if chunked?
        read_chunked dest
      else
        clen = content_length()
        if clen
          @socket.read clen, dest, true   # ignore EOF
        else
          clen = range_length()
          if clen
            @socket.read clen, dest
          else
            @socket.read_all dest
          end
        end
      end
    end

    def read_chunked(dest)
      len = nil
      total = 0
      while true
        line = @socket.readline
        hexlen = line.slice(/[0-9a-fA-F]+/) or
            raise HTTPBadResponse, "wrong chunk size line: #{line}"
        len = hexlen.hex
        break if len == 0
        @socket.read len, dest; total += len
        @socket.read 2   # \r\n
      end
      until @socket.readline.empty?
        # none
      end
    end

    def stream_check
      raise IOError, 'attempt to read body out of block' if @socket.closed?
    end

    def procdest(dest, block)
      raise ArgumentError, 'both arg and block given for HTTP method' \
          if dest and block
      if block
        ReadAdapter.new(block)
      else
        dest || ''
      end
    end

  end


  # :enddoc:

  # for backward compatibility
 
  class HTTP
    ProxyMod = ProxyDelta
  end
  module NetPrivate
    HTTPRequest = ::Net::HTTPRequest
  end

  HTTPInformationCode = HTTPInformation
  HTTPSuccessCode     = HTTPSuccess
  HTTPRedirectionCode = HTTPRedirection
  HTTPRetriableCode   = HTTPRedirection
  HTTPClientErrorCode = HTTPClientError
  HTTPFatalErrorCode  = HTTPClientError
  HTTPServerErrorCode = HTTPServerError
  HTTPResponceReceiver = HTTPResponse

end   # module Net
