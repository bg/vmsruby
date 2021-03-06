# Accumulate a running set of results, and report them at the end

# Will use this for triple-r instead of XML

#
require "yaml"
  
class ResultDisplay

  def initialize(gatherer)
    @gatherer = gatherer
  end

  def reportOn(op)
    # map errors to the corresponding string - for some reason
    # dump doesn't handle them

    @gatherer.results.each_value do |res|
      res.failures.each {|f| f.err = f.err.class.name + ": " + f.err.to_s }
      res.errors.each   {|f| f.err = f.err.class.name + ": " + f.err.to_s }
    end

    op << YAML.dump(@gatherer)
  end
end


