# frozen_string_literal: true

require_relative "lib/bake/releases/version"

Gem::Specification.new do |spec|
	spec.name = "bake-releases"
	spec.version = Bake::Releases::VERSION
	
	spec.summary = "Releases document management."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/ioquatix/bake-releases"
	
	spec.metadata = {
		"bug_tracker_uri" => "https://github.com/ioquatix/bake-releases/issues",
		"changelog_uri" => "https://github.com/ioquatix/bake-releases/blob/main/releases.md",
		"documentation_uri" => "https://ioquatix.github.io/bake-releases/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/ioquatix/bake-releases.git",
	}
	
	spec.files = Dir.glob(["{bake,context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.3"
	
	spec.add_dependency "bake", "~> 0.21"
	spec.add_dependency "markly", "~> 0.8"
end
