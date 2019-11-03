require 'ostruct'
require 'yaml'
require 'json'

class Object
  def to_openstruct
    self
  end
  def hashify
    self
  end
end

class OpenStruct
  def hashify
    h = self.to_h
    h.hashify
  end
end

class Array
  def to_openstruct
    map{ |el| el.to_openstruct }
  end
  def hashify
    map{ |el| el.hashify }
  end
end

class Hash
  def to_openstruct
    mapped = {}
    each{ |key,value| mapped[key] = value.to_openstruct }
    OpenStruct.new(mapped)
  end

  def hashify
    mapped = {}
    each{ |key,value| mapped[key] = value.hashify }
    mapped
  end

  def soft_merge(other)
    mapped = dup
    other.each{ |key,value| mapped[key] = value unless value.nil? }
    mapped
  end
end
