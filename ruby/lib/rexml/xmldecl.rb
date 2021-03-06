require 'rexml/encoding'
require 'rexml/source'

module REXML
	# NEEDS DOCUMENTATION
	class XMLDecl < Child
		include Encoding

		DEFAULT_VERSION = "1.0";
		DEFAULT_ENCODING = "UTF-8";
		DEFAULT_STANDALONE = "no";
		START = '<\?xml';
		STOP = '\?>';

		attr_accessor :version, :standalone
    attr_reader :writeencoding

		def initialize(version=DEFAULT_VERSION, encoding=nil, standalone=nil)
      @writethis = true
      @writeencoding = !encoding.nil?
			if version.kind_of? XMLDecl
				super()
				@version = version.version
				self.encoding = version.encoding
        @writeencoding = version.writeencoding
				@standalone = version.standalone
			else
				super()
				@version = version
				self.encoding = encoding
				@standalone = standalone
			end
			@version = DEFAULT_VERSION if @version.nil?
		end

		def clone
			XMLDecl.new(self)
		end

		def write writer, indent=-1, transitive=false, ie_hack=false
      return nil unless @writethis or writer.kind_of? Output
			indent( writer, indent )
			writer << START.sub(/\\/u, '')
      if writer.kind_of? Output
        writer << " #{content writer.encoding}"
      else
        writer << " #{content encoding}"
      end
			writer << STOP.sub(/\\/u, '')
		end

		def ==( other )
		  other.kind_of?(XMLDecl) and
		  other.version == @version and
		  other.encoding == self.encoding and
		  other.standalone == @standalone
		end

		def xmldecl version, encoding, standalone
			@version = version
			self.encoding = encoding
			@standalone = standalone
		end

		def node_type
			:xmldecl
		end

		alias :stand_alone? :standalone
    alias :old_enc= :encoding=

    def encoding=( enc )
      if enc.nil?
        self.old_enc = "UTF-8"
        @writeencoding = false
      else
        self.old_enc = enc
        @writeencoding = true
      end
      self.dowrite
    end

    def XMLDecl.default
      rv = XMLDecl.new( "1.0" )
      rv.nowrite
      rv
    end

    def nowrite
      @writethis = false
    end

    def dowrite
      @writethis = true
    end

		private
		def content(enc)
			rv = "version='#@version'"
			rv << " encoding='#{enc}'" if @writeencoding || enc !~ /utf-8/i
			rv << " standalone='#@standalone'" if @standalone
			rv
		end
	end
end
