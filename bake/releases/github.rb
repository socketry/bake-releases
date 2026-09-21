# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

# Publish a GitHub release for the given version.
#
# Requires a `source_code_uri` or `homepage` pointing to `github.com` in the gemspec.
# Uses the `gh` command-line tool to create the release.
# Release notes are extracted from `releases.md` for the given version; if none are found, the release is created with empty notes.
#
# @parameter tag [String] The tag name of the release, e.g. "v1.2.3".
def release(tag)
	require "tempfile"
	
	repo = github_repo
	notes = context["releases:notes"].call(tag.to_s)
	
	Tempfile.create(["release-notes", ".md"]) do |file|
		file.write(notes || "")
		file.flush
		
		system(
			"gh", "release", "create", tag.to_s,
			"--repo", repo,
			"--title", tag.to_s,
			"--notes-file", file.path
		) or raise "Failed to create GitHub release for #{tag}"
	end
end

private

GITHUB_URI_PATTERN = %r{github\.com[:/]+(?<repo>[^/\s]+/[^/\s]+?)(?:\.git)?$}

def github_repo
	gemspec_path = Dir.glob(File.join(context.root, "*.gemspec")).first
	raise "No gemspec found in #{context.root}" unless gemspec_path
	
	spec = ::Gem::Specification.load(gemspec_path)
	
	source_uri = spec.metadata&.dig("source_code_uri") || spec.homepage
	raise "No source_code_uri or homepage found in gemspec" unless source_uri
	
	match = GITHUB_URI_PATTERN.match(source_uri)
	raise "URI does not appear to be a GitHub repository: #{source_uri}" unless match
	
	match[:repo]
end
