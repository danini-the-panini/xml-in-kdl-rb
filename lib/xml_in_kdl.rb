# frozen_string_literal: true

require "kdl"
require "nokogiri"
require_relative "xml_in_kdl/version"
require_relative "xml_in_kdl/encoder"
require_relative "xml_in_kdl/decoder"

module XmlInKdl
  class Error < StandardError; end

  class << self
    def encode(xml)
      Encoder.encode(xml)
    end

    def encode_string(xml)
      encode(::Nokogiri::XML(xml))
    end

    def decode(kdl)
      Decoder.decode(kdl)
    end

    def decode_string(kdl)
      decode(::KDL.parse_document(kdl))
    end
  end
end
