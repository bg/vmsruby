# WSDL4R - WSDL XML Instance parser library.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/qname'
require 'xsd/ns'
require 'xsd/charset'
require 'xsd/datatypes'
require 'xsd/xmlparser'
require 'wsdl/xmlSchema/data'


module WSDL
module XMLSchema


class Parser
  include XSD

  class ParseError < Error; end
  class FormatDecodeError < Error; end
  class UnknownElementError < FormatDecodeError; end
  class UnknownAttributeError < FormatDecodeError; end
  class UnexpectedElementError < FormatDecodeError; end
  class ElementConstraintError < FormatDecodeError; end
  class AttributeConstraintError < FormatDecodeError; end

private

  class ParseFrame
    attr_reader :ns
    attr_reader :name
    attr_accessor :node

  private

    def initialize(ns, name, node)
      @ns = ns
      @name = name
      @node = node
    end
  end

public

  def initialize(opt = {})
    @parser = XSD::XMLParser.create_parser(self, opt)
    @parsestack = nil
    @lastnode = nil
  end

  def parse(string_or_readable)
    @parsestack = []
    @lastnode = nil
    @textbuf = ''
    @parser.do_parse(string_or_readable)
    @lastnode
  end

  def charset
    @parser.charset
  end

  def start_element(name, attrs)
    lastframe = @parsestack.last
    ns = parent = nil
    if lastframe
      ns = lastframe.ns.clone_ns
      parent = lastframe.node
    else
      ns = XSD::NS.new
      parent = nil
    end
    attrs = XSD::XMLParser.filter_ns(ns, attrs)
    node = decode_tag(ns, name, attrs, parent)
    @parsestack << ParseFrame.new(ns, name, node)
  end

  def characters(text)
    lastframe = @parsestack.last
    if lastframe
      # Need not to be cloned because character does not have attr.
      ns = lastframe.ns
      decode_text(ns, text)
    else
      p text if $DEBUG
    end
  end

  def end_element(name)
    lastframe = @parsestack.pop
    unless name == lastframe.name
      raise UnexpectedElementError.new("Closing element name '#{ name }' does not match with opening element '#{ lastframe.name }'.")
    end
    decode_tag_end(lastframe.ns, lastframe.node)
    @lastnode = lastframe.node
  end

private

  def decode_tag(ns, name, attrs, parent)
    o = nil
    element = ns.parse(name)
    if !parent
      if element == SchemaName
	o = Schema.parse_element(element)
      else
	raise UnknownElementError.new("Unknown element #{ element }.")
      end
    else
      o = parent.parse_element(element)
      unless o
	raise UnknownElementError.new("Unknown element #{ element }.")
      end
      # node could be a pseudo element.  pseudo element has its own parent.
      o.parent = parent if o.parent.nil?
    end
    attrs.each do |key, value|
      attr = unless /:/ =~ key
	  XSD::QName.new(nil, key)
	else
	  ns.parse(key)
	end
      value_ele = if /:/ !~ value
	  value
	elsif /^http:\/\// =~ value	# ToDo: ugly.
	  value
	else
	  begin
	    ns.parse(value)
	  rescue
	    value
	  end
	end
      if attr == IdAttrName
	o.id = value_ele
      else
	unless o.parse_attr(attr, value_ele)
	  STDERR.puts("Unknown attr #{ attr }.")
	  # raise UnknownAttributeError.new("Unknown attr #{ attr }.")
   	end
      end
    end
    o
  end

  def decode_tag_end(ns, node)
    node.parse_epilogue
  end

  def decode_text(ns, text)
    @textbuf << text
  end
end


end
end
