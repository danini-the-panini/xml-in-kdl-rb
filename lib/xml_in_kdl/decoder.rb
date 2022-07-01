module XmlInKdl
  module Decoder
    class << self
      def decode(kdl)
        xml_doc = ::Nokogiri::XML::Document.new
        kdl.nodes.each do |node|
          n = decode_node(node, xml_doc)
          xml_doc.add_child(n) unless n.nil?
        end
        xml_doc
      end

      private

      def decode_node(node, xml_doc)
        case node.name
        when /^\?/
          if node.properties['encoding']
            xml_doc.encoding = node.properties['encoding'].value
          end
          nil
        when /^!/
          ::Nokogiri::XML::DTD.new
        when '-'
          ::Nokogiri::XML::Text.new(node.arguments.first.value, xml_doc)
        else
          xml_doc.create_element(node.name, node.properties.transform_values { |v| v.value.to_s }).tap do |n|
            n.add_child(::Nokogiri::XML::Text.new(node.arguments.first.value, xml_doc)) unless node.arguments.empty?
            node.children.each do |c|
              n.add_child(decode_node(c, xml_doc))
            end
          end
        end
      end
    end
  end
end