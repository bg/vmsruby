# encoding: utf-8
# 
# keywords        =       "Keywords:" phrase *("," phrase) CRLF
module Mail
  class KeywordsField < StructuredField
    
    FIELD_NAME = 'keywords'
    CAPITALIZED_FIELD = 'Keywords'
    
    def initialize(*args)
      super(CAPITALIZED_FIELD, strip_field(FIELD_NAME, args.last))
    end
    
    def phrase_list
      @phrase_list ||= PhraseList.new(value)
    end
      
    def keywords
      phrase_list.phrases
    end
    
    def encoded
      "#{CAPITALIZED_FIELD}: #{keywords.join(', ')}\r\n"
    end
    
    def decoded
      keywords.join(', ')
    end
    
  end
end
