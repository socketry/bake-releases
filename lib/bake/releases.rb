# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "releases/version"
require "markly"

# @namespace
module Bake
	# Read and manage release documentation.
	module Releases
		# Extract a release section as Markdown without changing the source file.
		# The release heading is omitted and nested headings are promoted relative to it.
		#
		# @parameter tag [String] The exact release heading, e.g. "v1.2.3".
		# @parameter path [String] The releases document, relative to the current working directory unless absolute.
		# @returns [String | Nil] The release notes, or nil if the file, heading, or section content is missing.
		def self.notes(tag, path: "releases.md")
			return nil unless File.exist?(path)
			
			document = Markly.parse(File.read(path))
			header = document.find_header(tag.to_s)
			return nil unless header
			
			fragment = Markly::Node.new(:document)
			node = header.next
			while node
				break if node.type == :header && node.header_level <= header.header_level
				next_node = node.next
				fragment.append_child(node)
				node = next_node
			end
			
			return nil unless fragment.first_child
			
			offset = header.header_level - 1
			if offset > 0
				fragment.walk do |node|
					if node.type == :header
						node.header_level -= offset
					end
				end
			end
			
			fragment.to_markdown
		end
	end
end
