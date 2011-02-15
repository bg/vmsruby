# Autogenerated from a Treetop grammar. Edits may be lost.


module Mail
  module MimeVersion
    include Treetop::Runtime

    def root
      @root || :version
    end

    include RFC2822

    module Version0
      def CFWS1
        elements[0]
      end

      def major_digits
        elements[1]
      end

      def minor_digits
        elements[5]
      end

      def CFWS2
        elements[6]
      end
    end

    module Version1
      def major
        major_digits
      end
      
      def minor
        minor_digits
      end
    end

    def _nt_version
      start_index = index
      if node_cache[:version].has_key?(index)
        cached = node_cache[:version][index]
        @index = cached.interval.end if cached
        return cached
      end

      i0, s0 = index, []
      r1 = _nt_CFWS
      s0 << r1
      if r1
        s2, i2 = [], index
        loop do
          r3 = _nt_DIGIT
          if r3
            s2 << r3
          else
            break
          end
        end
        if s2.empty?
          @index = i2
          r2 = nil
        else
          r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
        end
        s0 << r2
        if r2
          r5 = _nt_comment
          if r5
            r4 = r5
          else
            r4 = instantiate_node(SyntaxNode,input, index...index)
          end
          s0 << r4
          if r4
            if has_terminal?(".", false, index)
              r6 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure(".")
              r6 = nil
            end
            s0 << r6
            if r6
              r8 = _nt_comment
              if r8
                r7 = r8
              else
                r7 = instantiate_node(SyntaxNode,input, index...index)
              end
              s0 << r7
              if r7
                s9, i9 = [], index
                loop do
                  r10 = _nt_DIGIT
                  if r10
                    s9 << r10
                  else
                    break
                  end
                end
                if s9.empty?
                  @index = i9
                  r9 = nil
                else
                  r9 = instantiate_node(SyntaxNode,input, i9...index, s9)
                end
                s0 << r9
                if r9
                  r11 = _nt_CFWS
                  s0 << r11
                end
              end
            end
          end
        end
      end
      if s0.last
        r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
        r0.extend(Version0)
        r0.extend(Version1)
      else
        @index = i0
        r0 = nil
      end

      node_cache[:version][start_index] = r0

      r0
    end

  end

  class MimeVersionParser < Treetop::Runtime::CompiledParser
    include MimeVersion
  end

end