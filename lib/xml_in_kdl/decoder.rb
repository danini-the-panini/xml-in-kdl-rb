# frozen_string_literal: true

module XmlInKdl
  class Decoder
    def initialize(kdl)
      @kdl = kdl
      @xml_doc = ::Nokogiri::XML::Document.new
    end

    def self.decode(kdl)
      new(kdl).decode
    end

    def decode
      @kdl.nodes.each do |kdl_node|
        xml_node = decode_node(kdl_node)
        @xml_doc.add_child(xml_node) unless xml_node.nil?
      end
      @xml_doc
    end

    private

    def decode_node(node)
      case node.name
      when /^\?/
        decode_directive(node)
      when '!'
        decode_comment(node)
      when /^!/
        decode_doctype(node)
      when '-'
        decode_text(node)
      else
        decode_element(node)
      end
    end

    DIRECTIVE_ERROR_STRING = "XiK directive nodes must only contain properties"
    def decode_directive(directive)
      raise Error, DIRECTIVE_ERROR_STRING unless directive.children.empty? && directive.arguments.empty?
      raise Error, DIRECTIVE_ERROR_STRING if directive.properties.values.any? { |v| !v.is_a?(::KDL::Value::String) }

      if directive.properties['version']
        @xml_doc = ::Nokogiri::XML::Document.new(directive.properties['version'].value)
      end
      if directive.properties['encoding']
        @xml_doc.encoding = directive.properties['encoding'].value
      end
      # TODO: more directives, e.g. "standalone"
      nil
    end

    COMMENT_ERROR_STRING = "XiK comment nodes must contain exactly one string argument and nothing else"
    def decode_comment(comment)
      raise Error, COMMENT_ERROR_STRING unless comment.children.empty? && comment.properties.empty?
      raise Error, COMMENT_ERROR_STRING unless comment.arguments.size == 1
      raise Error, COMMENT_ERROR_STRING unless comment.arguments.first.is_a?(::KDL::Value::String)

      ::Nokogiri::XML::Comment.new(@xml_doc, comment.arguments.first.value)
    end

    DOCTYPE_ERORR_STRING = "XiK doctype nodes must contain 1 to 3 string arguments and nothing else"
    def decode_doctype(doctype)
      raise Error, DOCTYPE_ERORR_STRING unless doctype.children.empty? && doctype.properties.empty?
      raise Error, DOCTYPE_ERORR_STRING unless doctype.arguments.size >= 1 && doctype.arguments.size <= 3
      raise Error, DOCTYPE_ERORR_STRING unless doctype.arguments.all? { |arg| arg.is_a?(::KDL::Value::String) }

      args = doctype.arguments.map(&:value)
      args << nil while args.length < 3
      @xml_doc.create_internal_subset(*args)
      nil
    end

    TEXT_ERORR_STRING = "XiK text nodes must contain exactly one string argument and nothing else"
    def decode_text(text)
      raise Error, TEXT_ERORR_STRING unless text.children.empty? && text.properties.empty?
      raise Error, TEXT_ERORR_STRING unless text.arguments.size == 1
      raise Error, TEXT_ERORR_STRING unless text.arguments.first.is_a?(::KDL::Value::String)

      decode_string(text.arguments.first)
    end

    STRING_ERROR_STRING = "XiK values must be strings"
    def decode_string(string)
      raise Error, STRING_ERROR_STRING unless string.is_a?(::KDL::Value::String)

      ::Nokogiri::XML::Text.new(string.value, @xml_doc)
    end

    ELEMENT_ERROR_STRING = "XiK elements must have either one string argument OR any number of children"
    def decode_element(element)
      if element.children.empty?
        raise Error, ELEMENT_ERROR_STRING unless element.arguments.size <= 1
      else
        raise Error, ELEMENT_ERROR_STRING unless element.arguments.empty?
      end
      raise Error, STRING_ERROR_STRING if element.properties.values.any? { |v| !v.is_a?(::KDL::Value::String) }

      node = @xml_doc.create_element(element.name, element.properties.transform_values { |v| v.value.to_s })
      if element.arguments.empty?
        element.children.each do |kdl_child|
          xml_child = decode_node(kdl_child)
          node.add_child(xml_child) unless xml_child.nil?
        end
      else
        node.add_child(decode_string(element.arguments.first)) unless element.arguments.empty?
      end
      node
    end
  end
end