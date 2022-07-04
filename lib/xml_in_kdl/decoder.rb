module XmlInKdl
  class Decoder
    def initialize(kdl)
      @kdl = kdl
      @xml_doc = ::Nokogiri::XML::Document.new
    end

    def self.decode(kdl)
      new(kdl).decode
    end

    def decode()
      @kdl.nodes.each do |node|
        n = decode_node(node)
      end
      @xml_doc
    end

    private

    def decode_node(node)
      case node.name
      when /^\?/
        if node.properties['version']
          @xml_doc = ::Nokogiri::XML::Document.new(node.properties['version'].value)
        end
        if node.properties['encoding']
          @xml_doc.encoding = node.properties['encoding'].value
        end
      when /^!/
        args = node.arguments.map(&:value)
        args << nil while args.length < 3
        @xml_doc.create_internal_subset(*args)
        nil
      when '-'
        text_node = ::Nokogiri::XML::Text.new(node.arguments.first.value, @xml_doc)
        @xml_doc.add_child(text_node)
      else
        element = @xml_doc.create_element(node.name, node.properties.transform_values { |v| v.value.to_s })
        element.add_child(::Nokogiri::XML::Text.new(node.arguments.first.value, @xml_doc)) unless node.arguments.empty?
        node.children.each do |c|
          element.add_child(decode_node(c))
        end
        @xml_doc.add_child(element)
      end
    end
  end
end