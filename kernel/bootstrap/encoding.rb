# -*- encoding: us-ascii -*-

class Encoding
  attr_reader :name
  attr_reader :dummy

  alias_method :to_s, :name
  alias_method :dummy?, :dummy

def self.compatible?(a,b)

  if (a.respond_to?(:encoding) && b.respond_to?(:encoding))
    enc_a = a.encoding
    enc_b = b.encoding
  elsif (a.is_a?(Encoding) && b.is_a?(Encoding))
    return a if a == b
    return nil if a.dummy? || b.dummy?
    return a if b == Encoding::US_ASCII
    return nil unless (a == Encoding::US_ASCII || b == Encoding::US_ASCII)
    return nil
  elsif (a.is_a?(Encoding) && b.respond_to?(:encoding))
    enc_a = a
    enc_b = b.encoding
  elsif (a.respond_to?(:encoding) && b.is_a?(Encoding))
    enc_a = a.encoding
    enc_b = b
  else
    return nil
  end

  a_s = a.is_a?(String) ? a : a.to_s
  b_s = b.is_a?(String) ? b : b.to_s

  return nil if enc_a.nil? || enc_b.nil?
  return enc_a if enc_a == enc_b

  return enc_a if b_s.empty?

  ascii_b = b_s.ascii_only?

  if a_s.empty?
    if enc_a.ascii_compatible? && ascii_b
      return enc_a
    else
      return enc_b
    end
  end

  return nil if !enc_a.ascii_compatible? || !enc_b.ascii_compatible?
  return enc_a if !b && enc_b == Encoding::US_ASCII
  return enc_b if !a && enc_a == Encoding::US_ASCII
  return nil if a.nil? && b.nil?

  ascii_a = a_s.ascii_only?

  if b.nil?
    return enc_b if ascii_a
  end

  if ascii_a != ascii_b
    return enc_a if !ascii_a || ascii_b
    return enc_b if ascii_a
  end

  return enc_a if ascii_b
  return enc_b if ascii_a

  return nil
end

  def replicate(name)
    Rubinius.primitive :encoding_replicate
    raise PrimitiveFailure, "Encoding#replicate primitive failed"
  end

  def ascii_compatible?
    Rubinius.primitive :encoding_ascii_compatible_p
    raise PrimitiveFailure, "Encoding#ascii_compatible? primitive failed"
  end
end
