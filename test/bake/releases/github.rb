# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "bake"
require "sus/fixtures/temporary_directory_context"

describe "releases:github:release" do
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:context) {Bake::Context.load(root)}
	let(:task) {context["releases:github:release"]}
	let(:calls) {[]}
	
	before do
		File.write(File.join(root, "example.gemspec"), <<~RUBY)
			::Gem::Specification.new do |spec|
				spec.name = "example"
				spec.version = "1.2.3"
				spec.metadata["source_code_uri"] = "https://github.com/socketry/example.git"
			end
		RUBY
		
		mock(task.instance) do |mock|
			mock.replace(:system) do |*arguments|
				calls << {arguments: arguments, notes: File.read(arguments.last)}
				true
			end
		end
	end
	
	it "creates the release with notes for the selected version" do
		File.write(File.join(root, "releases.md"), <<~MARKDOWN)
			## Unreleased
			
			Future changes.
			
			## v1.2.3
			
			  - Fixed a bug.
			
			### Details
			
			Release details.
		MARKDOWN
		
		task.call("v1.2.3")
		
		expect(calls.size).to be == 1
		expect(calls.first[:arguments][0...-1]).to be == [
			"gh", "release", "create", "v1.2.3",
			"--repo", "socketry/example",
			"--title", "v1.2.3",
			"--notes-file",
		]
		expect(calls.first[:notes]).to be == "  - Fixed a bug.\n\n## Details\n\nRelease details.\n"
		expect(File).not.to be(:exist?, calls.first[:arguments].last)
	end
	
	it "creates the release with empty notes when none exist" do
		task.call("v1.2.3")
		
		expect(calls.size).to be == 1
		expect(calls.first[:notes]).to be == ""
	end
end
