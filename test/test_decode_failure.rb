# frozen_string_literal: true

require "test_helper"

class TestDecodeFailure < Minitest::Test
  INVALID_KDL_DIR = File.join(__dir__, 'kdl', 'invalid')

  Dir.glob(File.join(INVALID_KDL_DIR, '*.kdl')).each do |kdl_path|
    input_name = File.basename(kdl_path, '.kdl')

    define_method "test_decode_invalid_#{input_name}_raises_error" do
      kdl = ::KDL.parse_document(File.read(kdl_path))
      assert_raises(XmlInKdl::Error) { XmlInKdl.decode(kdl) }
    end
  end
end
