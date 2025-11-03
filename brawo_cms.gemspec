require_relative "lib/brawo_cms/version"

Gem::Specification.new do |spec|
  spec.name        = "brawo_cms"
  spec.version     = BrawoCms::VERSION
  spec.authors     = ["Brawo CMS"]
  spec.email       = ["info@brawocms.com"]
  spec.homepage    = "https://github.com/brawo/brawo_cms"
  spec.summary     = "A flexible CMS engine for Rails"
  spec.description = "BrawoCMS is a flexible, developer-friendly CMS engine for Rails applications"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/brawo/brawo_cms"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.0"
  spec.add_dependency "pg", "~> 1.5"
end

