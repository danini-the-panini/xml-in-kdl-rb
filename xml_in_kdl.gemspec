# frozen_string_literal: true

require_relative "lib/xml_in_kdl/version"

Gem::Specification.new do |spec|
  spec.name = "xml_in_kdl"
  spec.version = XmlInKdl::VERSION
  spec.authors = ["Danielle Smith"]
  spec.email = ["danini@hey.com"]

  spec.summary = "XML-in-KDL (aka XiK)"
  spec.description = "Allows XML to be encoded as KDL"
  spec.homepage = "https://github.com/kdl-org/kdl/blob/main/XML-IN-KDL.md"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/danini-the-panini/xml-in-kdl-rb"
  spec.metadata["changelog_uri"] = "https://github.com/danini-the-panini/xml-in-kdl-rb/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "kdl", "~> 1.0"
  spec.add_dependency "nokogiri", "~> 1.13"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
