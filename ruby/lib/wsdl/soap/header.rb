# WSDL4R - WSDL SOAP body definition.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module SOAP


class Header < Info
  attr_reader :headerfault

  attr_reader :message	# required
  attr_reader :part	# required
  attr_reader :use	# required
  attr_reader :encodingstyle
  attr_reader :namespace

  def initialize
    super
    @message = nil
    @part = nil
    @use = nil
    @encodingstyle = nil
    @namespace = nil
    @headerfault = nil
  end

  def find_message
    root.message(@message)
  end

  def find_part
    find_message.parts.each do |part|
      if part.name == @part
	return part
      end
    end
    nil
  end

  def parse_element(element)
    case element
    when HeaderFaultName
      o = WSDL::SOAP::HeaderFault.new
      @headerfault = o
      o
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when MessageAttrName
      @message = value
    when PartAttrName
      @part = value
    when UseAttrName
      @use = value
    when EncodingStyleAttrName
      @encodingstyle = value
    when NamespaceAttrName
      @namespace = value
    else
      nil
    end
  end
end


end
end
