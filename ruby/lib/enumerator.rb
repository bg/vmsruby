# http://github.com/evanphx/rubinius/tree/master/lib/enumerator.rb
# A class which provides a method `each' to be used as an Enumerable
# object.
 
module Enumerable
  class Enumerator
    include Enumerable
 
    def initialize(obj,iter, *args)
      @object = obj
      @iter = iter
      @iterator = @object.method(iter.to_sym)
      @args = args
    end
 
    def each(&block)
      @iterator.call(*@args, &block)
    end
  end
 
  def each_cons(n, &block)
    array = []
    elements = self.to_a
    while elements.size > 0 do
      array << elements[0,n] if elements[0,n].size == n
      elements.shift
    end
    array.each { |set| yield set }
    nil
  end
 
  def enum_cons(n)
    Enumerable::Enumerator.new(self, :each_cons, n)
  end
 
  def each_slice(slice_size, &block)
    a = []
    each { |element|
      a << element
      if a.length == slice_size
        yield a
        a = []
      end
    }
    yield a if a.length > 0
  end
 
  def enum_slice(n)
    Enumerable::Enumerator.new(self, :each_slice, n)
  end
 
  def enum_with_index
    Enumerable::Enumerator.new(self, :each_with_index)
  end
end
 
class Object
  def enum_for(method, *args)
    Enumerable::Enumerator.new(self,method,*args)
  end
end
