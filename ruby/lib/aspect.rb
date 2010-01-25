module Aspect

    # Auto-generated symbol support (used in aliasing)
    @@symbol=0

    def self.generated_symbol
        "__Aspect_#{@@symbol+=1}__"
    end

    # Weave aspect related code into specified instance method:
    # - Parameters
    #   - class_name  name of class containing the specified method
    #   - method_name specified method name
    #   - advice        hash of optional source code strings to be woven into method at designated points
    #     :before       insert code before method is called
    #     :returning    insert code which will be executed after a non-exception return
    #     :throwing     insert code to be executed if method exception is raised
    #     :after        insert code after method exit (exceptions or non-exception case)
    #   - alias_name    optional override aliased name of original method (default is auto-generated)
    #     (auto-generated symbols which support nested aspects is preferred)
    #   - for_singleton *INTERNAL ONLY* indicates that specified method is a singleton method (default=instance method)
    #     (singleton is specified for class methods or object singletons)
    # - Notes:
    #   - method inputs can be referenced via 'args'
    #   - yield blocks can be referenced via 'block'
    #   - return results can be referenced via 'result'
    def self.weave class_name,method_name,advice,alias_name=nil,for_singleton=false
        begin
            alias_name=generated_symbol unless alias_name
            code=nil

            code_generator=proc{|*args|
                eval code=generate_code(for_singleton,!args.empty?,class_name,method_name,advice,alias_name),
                    TOPLEVEL_BINDING}

            begin
                code_generator.call
            rescue NameError
                code_generator.call :missing
            end
        ensure
            $stderr.puts code if $DEBUG
        end
    end

    # Weave aspect related code into class class methods (or objects singleton methods)
    # - same parameters as Aspect.weave
    class << self
        def class_weave class_name,method_name,advice,alias_name=nil
            self.weave class_name,method_name,advice,alias_name=nil,singleton=true
        end

        alias singleton_object_weave class_weave
    end

    private

    # Weave user supplied advice code into specified method
    # - parameters
    #   - singleton     true if method is a class method or singleton object method otherwise instance method
    #   - missing       true if weaving missing_method wrapper
    #   - class_name    name of class containing the specified method
    #   - method_name   specified method name
    #   - advice        hash of optional source code strings to be weaved into method (see Aspect#weave)
    #   - alias_name    optional override aliased name of original method (see Aspect#weave)
    def self.generate_code singleton,missing,class_name,method_name,advice,alias_name
        wrap=%[
            begin
                #{advice[:before]}
                result=(#{alias_name+"(#{'name,' if missing}*args,&block)"})
                #{advice[:returning]}
            rescue Exception
                #{advice[:throwing] or 'raise'}
            ensure
                #{advice[:after]}
            end
            result
        ]

        # Method_missing specific wrapping
        missing_wrap=%[
            if name == :#{method_name}
                #{wrap}
            else
                #{alias_name} name,*args,&block
            end
        ]

        # Handle Class, Instance and missing_method variants
        %[ class #{'<<' if singleton} #{class_name}
               alias #{alias_name} #{missing ? 'method_missing' :method_name}
               def #{missing ? 'method_missing name,' : method_name} *args,&block
                   #{missing ? missing_wrap : wrap}
               end
           end ]
    end
end
