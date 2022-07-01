module XmlInKdl
  module Encoder
    class << self
      def encode(xml)
        encoding_node = encode_encoding(xml.encoding)
        children = xml.children.map { |c| encode_node(c) }
        ::KDL::Document.new([encoding_node, *children].compact)
      end

      private

      def encode_node(node)
        case node
        when Nokogiri::XML::Element
          encode_element(node)
        when Nokogiri::XML::Text
          encode_text(node)
        when Nokogiri::XML::DTD
          encode_dtd(node)
        end
      end

      def encode_element(element)
        arguments = []
        children = []
        properties = element.attributes.map { |key, value| [key, ::KDL::Value.from(value.value)] }.to_h
        if !properties.empty? || element.children.any? { |c| c.is_a?(Nokogiri::XML::Element) }
          children = element.children.map { |c| encode_node(c) }.compact
        elsif element.children.first.is_a?(Nokogiri::XML::Text)
          content = element.children.first.content.strip
          arguments = [::KDL::Value.from(element.children.first.content.strip)] unless content.empty?
        end
        ::KDL::Node.new(element.name, arguments, properties, children)
      end

      def encode_text(text)
        content = text.content.strip
        return nil if content.empty?

        ::KDL::Node.new('-', [::KDL::Value.from(content)])
      end

      def encode_dtd(dtd)
        ::KDL::Node.new('!doctype', [::KDL::Value.from(dtd.name)])
      end

      def encode_encoding(encoding)
        return nil if encoding.nil?

        ::KDL::Node.new('?xml', [], { 'encoding' => KDL::Value.from(encoding) })
      end
    end
  end
end