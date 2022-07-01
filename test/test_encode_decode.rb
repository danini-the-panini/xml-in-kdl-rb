# frozen_string_literal: true

require "test_helper"

class TestEncodeDecode < Minitest::Test
  XML_DIR = File.join(__dir__, 'xml')
  KDL_DIR = File.join(__dir__, 'kdl')

  Dir.glob(File.join(XML_DIR, '*.xml')).each do |xml_path|
    input_name = File.basename(xml_path, '.xml')
    kdl_path = File.join(KDL_DIR, "#{input_name}.kdl")
    
    define_method "test_encode_#{input_name}_matches_expected_output" do
      xml = ::Nokogiri::XML(File.read(xml_path))
      kdl = ::KDL.parse_document(File.read(kdl_path))
      assert_equal kdl, XmlInKdl.encode(xml)
    end

    define_method "test_decode_#{input_name}_matches_expected_output" do
      xml = ::Nokogiri::XML(File.read(xml_path))
      kdl = ::KDL.parse_document(File.read(kdl_path))
      assert_equal xml.to_s, XmlInKdl.decode(kdl).to_s
    end
  end
end
