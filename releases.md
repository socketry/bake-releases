# Releases

## v0.6.0

  - Extract release notes without publishing using `Bake::Releases.notes` or the `releases:notes` Bake task.

## v0.5.4

  - Fix ambiguous constant name `Gem::Specification` -\> `::Gem::Specification`.

## v0.5.3

  - Don't strip whitespace from release notes.
  - It breaks markdown formatting (this is a test).

## v0.5.2

  - Remove `--clobber` from GitHub release - it was a hallucination and doesn't exist.

## v0.5.1

  - Fix `tag_name` -\> `tag` in `after_gem_release` hook.

## v0.5.0

  - Add support for automatic GitHub release creation.

## v0.4.0

  - Add documentation and agent context.

## v0.3.0

  - Rename `changes` -\> `releases`.

## v0.2.0

  - Directly use supplied version.

## v0.1.0

  - Initial implementation.
