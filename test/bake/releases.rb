# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

require "bake"
require "bake/releases"
require "sus/fixtures/temporary_directory_context"
require "sus/fixtures/isolated_ruby_context"

describe Bake::Releases do
	it "has a version number" do
		expect(Bake::Releases::VERSION).to be =~ /^\d+\.\d+\.\d+$/
	end
	
	with ".notes" do
		include Sus::Fixtures::TemporaryDirectoryContext
		include Sus::Fixtures::IsolatedRubyContext
		
		let(:path) {File.join(root, "releases.md")}
		
		it "selects the exact version and preserves Markdown and the source file" do
			document = <<~MARKDOWN
				# Releases
				
				## Unreleased
				
				Future changes.
				
				## v2.0.0
				
				Newer release.
				
				## v1.2.3
				
				  - Keep `inline code` and **emphasis**.
				  - Read the [guide](https://example.com/guide).
				
				### Usage
				
				``` ruby
				puts "Hello"
				```
				
				#### Details
				
				More details.
				
				## v1.0.0
				
				Older release.
			MARKDOWN
			File.write(path, document)
			
			expect(subject.notes("v1.2.3", path: path)).to be == <<~MARKDOWN
				  - Keep `inline code` and **emphasis**.
				  - Read the [guide](https://example.com/guide).
				
				## Usage
				
				``` ruby
				puts "Hello"
				```
				
				### Details
				
				More details.
			MARKDOWN
			expect(File.read(path)).to be == document
			expect(subject.notes("1.2.3", path: path)).to be_nil
		end
		
		it "reads the last release through the end of the document" do
			File.write(path, "## v1.2.3\n\nRelease notes.\n")
			
			expect(subject.notes("v1.2.3", path: path)).to be == "Release notes.\n"
		end
		
		it "stops at a heading above the release level" do
			File.write(path, "## v1.2.3\n\nRelease notes.\n\n# Appendix\n\nOther content.\n")
			
			expect(subject.notes("v1.2.3", path: path)).to be == "Release notes.\n"
		end
		
		it "keeps nested heading levels for a top-level release heading" do
			File.write(path, "# v1.2.3\n\n## Features\n\nRelease notes.\n")
			
			expect(subject.notes("v1.2.3", path: path)).to be == "## Features\n\nRelease notes.\n"
		end
		
		it "returns nil when the file is missing" do
			expect(subject.notes("v1.2.3", path: path)).to be_nil
		end
		
		it "returns nil when the release heading is missing" do
			File.write(path, "## Unreleased\n\nFuture changes.\n")
			
			expect(subject.notes("v1.2.3", path: path)).to be_nil
		end
		
		it "returns nil when the release section is empty" do
			File.write(path, "## v1.2.3\n\n## v1.0.0\n\nOlder notes.\n")
			
			expect(subject.notes("v1.2.3", path: path)).to be_nil
		end
		
		it "defaults to releases.md in the working directory" do
			File.write(path, "## v1.2.3\n\nRelease notes.\n")
			
			notes = isolated_ruby('Bake::Releases.notes("v1.2.3")', requires: ["bake/releases"], chdir: root)
			
			expect(notes).to be == "Release notes.\n"
		end
	end
	
	with "releases:notes" do
		include Sus::Fixtures::TemporaryDirectoryContext
		
		let(:context) {Bake::Context.load(root)}
		
		it "reads notes from the project root" do
			File.write(File.join(root, "releases.md"), "## v1.2.3\n\nRelease notes.\n")
			
			expect(context["releases:notes"].call("v1.2.3")).to be == "Release notes.\n"
		end
		
		it "accepts a custom document path" do
			path = File.join(root, "changes.md")
			File.write(path, "## v1.2.3\n\nCustom notes.\n")
			
			expect(context["releases:notes"].call("v1.2.3", path: path)).to be == "Custom notes.\n"
		end
		
		it "returns nil when no notes exist" do
			expect(context["releases:notes"].call("v1.2.3")).to be_nil
		end
	end
	
	let(:project_root) {File.expand_path(".project", __dir__)}
	let(:context) {Bake::Context.load(project_root)}
	
	it "can update releases document" do
		releases_path = File.join(project_root, "releases.md")
		
		File.write(releases_path, <<~DOCUMENT)
			# Releases
			
			## Unreleased
			
			  - Fixed a bug.
			
			## v0.0.0
			
			  - First release.
		DOCUMENT
		
		context["releases:update"].call("v1.0.0")
		
		expect(File.read(releases_path)).to be == <<~DOCUMENT
			# Releases
			
			## v1.0.0
			
			  - Fixed a bug.
			
			## v0.0.0
			
			  - First release.
		DOCUMENT
	ensure
		File.unlink(releases_path)
	end
end
