# http://github.com/evanphx/rubinius/blob/8a9a010e5f52408e3b87d08e107d13f0eb189877/lib/enumerator_186.rb
# - bg> with my modifications to make compatible with VMSRuby
#   - no "Type.coerce_to" available
# A class which provides a method `each' to be used as an Enumerable
# object.

# Provide dummy implementations for Rubinius bits we don't have:
module Type
  def self.coerce_to(obj, cls, meth)
    obj
  end
end
#

module Enumerable
  class Enumerator
    include Enumerable

    def initialize(obj, iter = :each, *args, &block)
      @object = obj
      @iter = iter.to_sym
      @args = args
    end

    def each(&block)
      @object.send(@iter, *@args, &block)
    end
  end
end

module Enumerable
  undef each_cons if instance_methods.include? 'each_cons'
  def each_cons(num)
    n = Type.coerce_to(num, Fixnum, :to_int)
    raise ArgumentError, "invalid size: #{n}" if n <= 0
    array = []
    each do |element|
      array << element
      array.shift if array.size > n
      yield array.dup if array.size == n
    end
    nil
  end

  undef each_slice if instance_methods.include? 'each_slice'
  def each_slice(slice_size)
    n = Type.coerce_to(slice_size, Fixnum, :to_int)
    raise ArgumentError, "invalid slice size: #{n}" if n <= 0
    a = []
    each do |element|
      a << element
      if a.length == n
        yield a
        a = []
      end
    end
    yield a unless a.empty?
    nil
  end

  def enum_cons(n)
    Enumerable::Enumerator.new(self, :each_cons, n)
  end

  def enum_slice(n)
    Enumerable::Enumerator.new(self, :each_slice, n)
  end

  def enum_with_index
    Enumerable::Enumerator.new(self, :each_with_index)
  end

  def first(*args)
    _first=proc do |count|
      result=[]
      each do |_|
        break if result.size==count
        result << _
      end
      result
    end
    case args.size
    when 0 then _first[1].first
    when 1 then _first[*args]
    else raise ArgumentError
    end
  end
end

module Kernel
  def enum_for(method = :each, *args)
    Enumerable::Enumerator.new(self,method,*args)
  end
  
  alias_method :to_enum, :enum_for
end
