# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2026, by Samuel Williams.

# Extract the Markdown notes for a release without publishing it.
#
# @parameter tag [String] The exact release heading, e.g. "v1.2.3".
# @parameter path [String] The releases document. Defaults to releases.md in the project root.
# @returns [String | Nil] The release notes, or nil if no notes exist.
def notes(tag, path: self.releases_path)
	require_relative "../lib/bake/releases"
	
	Bake::Releases.notes(tag, path: path)
end

# Update the 'Unreleased' section of the releases document with the given version number, if it exists.
#
# The version number can be any string, but ideally follows the semantic versioning scheme with a "v" prefix.
#
# @parameter version [String] The version number to release.
def update(version)
	self.update_document do |document|
		if node = document.find_header("Unreleased")
			# Create a new text node with the version number:
			child = Markly::Node.new(:text)
			child.string_content = version.to_s
			
			# Delete all current children, and replace it with the version number:
			node.extract_children
			node.append_child(child)
		end
	end
end

private

def releases_path(root = context.root)
	File.join(root, "releases.md")
end

def update_document(path = self.releases_path)
	require "markly"
	
	if File.exist?(path)
		document = Markly.parse(File.read(path))
		
		yield document
		
		File.write(path, document.to_markdown)
	end
end
