# SOAP4R - WEBrick HTTP Server
# Copyright (C) 2003, 2004 by NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'logger'
require 'soap/rpc/soaplet'
require 'soap/streamHandler'
require 'webrick'


module SOAP
module RPC


class HTTPServer < Logger::Application
  attr_reader :server
  attr_accessor :default_namespace

  def initialize(config)
    super(config[:SOAPHTTPServerApplicationName] || self.class.name)
    @default_namespace = config[:SOAPDefaultNamespace]
    @webrick_config = config.dup
    @webrick_config[:Logger] ||= @log
    @server = nil
    @soaplet = ::SOAP::RPC::SOAPlet.new
    self.level = Logger::Severity::INFO
    on_init
  end

  def on_init
    # define extra methods in derived class.
  end

  def status
    if @server
      @server.status
    else
      nil
    end
  end

  def shutdown
    @server.shutdown if @server
  end
  
  def mapping_registry
    @soaplet.app_scope_router.mapping_registry
  end

  def mapping_registry=(mapping_registry)
    @soaplet.app_scope_router.mapping_registry = mapping_registry
  end

  def add_rpc_request_servant(factory, namespace = @default_namespace,
      mapping_registry = nil)
    @soaplet.add_rpc_request_servant(factory, namespace, mapping_registry)
  end

  def add_rpc_servant(obj, namespace = @default_namespace)
    @soaplet.add_rpc_servant(obj, namespace)
  end
  
  def add_rpc_request_headerhandler(factory)
    @soaplet.add_rpc_request_headerhandler(factory)
  end

  def add_rpc_headerhandler(obj)
    @soaplet.add_rpc_headerhandler(obj)
  end

  def add_method(obj, name, *param)
    add_method_as(obj, name, name, *param)
  end

  def add_method_as(obj, name, name_as, *param)
    qname = XSD::QName.new(@default_namespace, name_as)
    soapaction = nil
    method = obj.method(name)
    param_def = if param.size == 1 and param[0].is_a?(Array)
        param[0]
      elsif param.empty?
	::SOAP::RPC::SOAPMethod.create_param_def(
	  (1..method.arity.abs).collect { |i| "p#{ i }" })
      else
        SOAP::RPC::SOAPMethod.create_param_def(param)
      end
    @soaplet.app_scope_router.add_method(obj, qname, soapaction, name, param_def)
  end

private

  def run
    @server = WEBrick::HTTPServer.new(@webrick_config)
    @server.mount('/', @soaplet)
    @server.start
  end
end


end
end
