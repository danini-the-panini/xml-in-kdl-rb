module XmlInKdl
  module Decoder
    class << self
      def decode(xml)
        ::Nokogiri::XML::Document.new
      end
    end
  end
end