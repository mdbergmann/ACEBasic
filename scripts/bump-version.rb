#!/usr/bin/env ruby
# bump-version.rb - Update all version references from the VERSION file
#
# Usage:
#   ruby scripts/bump-version.rb          # Apply changes
#   ruby scripts/bump-version.rb --dry-run # Show what would change
#
# Reads the version from the VERSION file in the project root and updates
# all known locations. The date in ver.c's $VER string is set to today.

require 'date'

# Resolve project root (one level up from scripts/)
SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))
ROOT = File.dirname(SCRIPT_DIR)

dry_run = ARGV.include?('--dry-run')

# Read new version
version_file = File.join(ROOT, 'VERSION')
unless File.exist?(version_file)
  $stderr.puts "ERROR: VERSION file not found at #{version_file}"
  exit 1
end

new_version = File.read(version_file).strip
unless new_version.match?(/^\d+\.\d+\.\d+$/)
  $stderr.puts "ERROR: Invalid version format '#{new_version}' (expected X.Y.Z)"
  exit 1
end

# AmigaDOS $VER date format: DD.MM.YY
today_amiga = Date.today.strftime('%d.%m.%y')

# Each entry: [relative_path, description, pattern, replacement]
# pattern matches the old version string in context; replacement inserts the new one
updates = [
  [
    'src/ace/c/ver.c',
    '$VER string',
    /(\$VER: ACE )\d+\.\d+\.\d+( \()\d+\.\d+\.\d+(\)")/,
    "\\1#{new_version}\\2#{today_amiga}\\3"
  ],
  [
    'src/ace/c/ver.c',
    'version_string',
    /(version_string = ")\d+\.\d+\.\d+(")/,
    "\\1#{new_version}\\2"
  ],
  [
    'README.md',
    'Current version badge',
    /(Current version: \*\*)\d+\.\d+(?:\.\d+)?(\*\*)/,
    "\\1#{new_version}\\2"
  ],
  [
    'docs/ref.txt',
    'title box',
    /(\| ACE v)\d+\.\d+\.\d+( \|)/,
    "\\1#{new_version}\\2"
  ],
  [
    'docs/ace.txt',
    'title box',
    /(\| ACE v)\d+\.\d+\.\d+( \|)/,
    "\\1#{new_version}\\2"
  ],
  [
    'docs/txt2guide.rb',
    'generated guide title',
    /(\| ACE v)\d+\.\d+\.\d+( \|)/,
    "\\1#{new_version}\\2"
  ],
  [
    'aminet.readme',
    'Version field',
    /(Version:\s+)\d+\.\d+\.\d+/,
    "\\1#{new_version}"
  ],
]

changed = 0
errors = 0

updates.each do |rel_path, desc, pattern, replacement|
  path = File.join(ROOT, rel_path)

  unless File.exist?(path)
    $stderr.puts "  SKIP  #{rel_path} (file not found)"
    next
  end

  content = File.read(path)

  unless content.match?(pattern)
    $stderr.puts "  MISS  #{rel_path} — #{desc} (pattern not found)"
    errors += 1
    next
  end

  new_content = content.sub(pattern, replacement)

  if new_content == content
    puts "  OK    #{rel_path} — #{desc} (already #{new_version})"
    next
  end

  if dry_run
    puts "  WOULD #{rel_path} — #{desc}"
  else
    File.write(path, new_content)
    puts "  DONE  #{rel_path} — #{desc}"
  end
  changed += 1
end

puts
if dry_run
  puts "Dry run: #{changed} file(s) would be updated to #{new_version}"
else
  puts "Updated #{changed} file(s) to #{new_version}"
end

if errors > 0
  $stderr.puts "WARNING: #{errors} pattern(s) did not match — check manually"
  exit 1
end
