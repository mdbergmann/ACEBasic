#!/usr/bin/env ruby
# txt2guide.rb - Convert ACE documentation text files to AmigaGuide format
#
# Usage:
#   ruby txt2guide.rb ref.txt > ref.guide
#   ruby txt2guide.rb ace.txt > ACE.guide

require 'set'

SEPARATOR = '-' * 80

# Known command names for cross-reference linking
# This will be populated during parsing
$known_commands = Set.new

class RefConverter
  def initialize(content)
    @content = content
    @entries = []
    @intro = ""
  end

  def parse
    # Split on separator lines
    parts = @content.split(/\n#{SEPARATOR}\n/)

    # First part is the introduction
    @intro = parts.shift.strip

    # Parse each entry
    parts.each do |part|
      next if part.strip.empty?
      entry = parse_entry(part)
      @entries << entry if entry
    end

    # Collect all command names for cross-referencing
    @entries.each { |e| $known_commands.add(e[:name]) }
  end

  def parse_entry(text)
    lines = text.strip.split("\n")
    return nil if lines.empty?

    # Extract command name from first line
    # Format: "COMMAND [*]" or "COMMAND    - description"
    first_line = lines.first

    # Handle special cases first:
    # "GADGET ON .." -> "GADGET ON"
    # "GADGET (GadTools)" -> "GADGET (GadTools)"
    # "PEEKx" or "POKEx" -> keep as is
    # "INPUT #" -> "INPUT #"

    # Remove trailing ".." or "..." from command names
    clean_line = first_line.gsub(/\s+\.\.\.?/, ' ')

    # Match command name patterns:
    # 1. COMMAND with optional spaces and modifiers (ON, OFF, CLOSE, etc.)
    # 2. May have $ or # suffix
    # 3. May have (parenthetical note)
    # 4. May have .. between parts like SUB..END SUB

    # Try to match compound commands first (e.g., "SLEEP FOR", "GADGET ON")
    match = clean_line.match(/^([A-Z][A-Z0-9$#x]*(?:\.\.[A-Z]+[A-Z0-9$#]*)?(?:\s+(?:[A-Z]+[A-Z0-9$#]*|#))*(?:\s+\([A-Za-z]+\))?)\s*[\*\-\t]/)

    unless match
      # Try simpler pattern
      match = clean_line.match(/^([A-Z][A-Z0-9$#x]+)\s/)
    end

    return nil unless match

    name = match[1].strip

    # Normalize: remove extra spaces
    name = name.gsub(/\s+/, ' ')

    {
      name: name,
      content: text.strip
    }
  end

  def convert_references(text)
    result = text.dup

    # Convert "ace.txt" references to alink
    result.gsub!(/\bace\.txt\b/, '@{"ace.guide" alink ace:docs/ace.guide/main}')

    # Convert "See also X, Y, Z" patterns
    # This regex finds "See also" followed by command references
    result.gsub!(/See also\s+([^.]+)\.?/) do |match|
      refs = $1
      converted_refs = convert_see_also_refs(refs)
      "See also #{converted_refs}."
    end

    # Convert standalone command references in parentheses like "(see COMMAND)"
    result.gsub!(/\(see\s+([A-Z][A-Z0-9$#\.]+)\)/) do |match|
      cmd = $1
      if $known_commands.include?(cmd)
        "(see @{\"#{cmd}\" link \"#{cmd}\"})"
      else
        match
      end
    end

    result
  end

  def convert_see_also_refs(refs_str)
    # Split on comma, "and", or similar
    parts = refs_str.split(/,\s*|\s+and\s+/)

    parts.map do |part|
      part = part.strip
      # Check if this looks like a command name
      if part.match?(/^[A-Z][A-Z0-9$#\.\s]+$/) && !part.match?(/^[A-Z][a-z]/)
        # Normalize the command name
        cmd = part.strip
        if $known_commands.include?(cmd)
          "@{\"#{cmd}\" link \"#{cmd}\"}"
        else
          part
        end
      else
        part
      end
    end.join(', ')
  end

  def generate_guide
    output = []

    # Header
    output << '@DATABASE "ref.doc"'
    output << '@INDEX INDEXNODE'
    output << '@MASTER ref.doc'

    # Main menu node
    output << '@NODE MAIN "Main Menu"'
    output << ' '
    output << generate_main_menu
    output << '@ENDNODE'

    # Introduction node
    output << '@NODE "Introduction" "Introduction"'
    output << @intro
    output << ' '
    output << '@ENDNODE'

    # Command nodes
    @entries.sort_by { |e| e[:name] }.each do |entry|
      output << "@NODE \"#{entry[:name]}\" \"#{entry[:name]}\""
      output << convert_references(entry[:content])
      output << ' '
      output << '@ENDNODE'
    end

    # Index node
    output << '@NODE INDEXNODE "Index"'
    output << generate_index
    output << '@ENDNODE'

    output.join("\n")
  end

  def generate_main_menu
    # Generate a compact multi-column menu like the original
    lines = []

    # Sort entries alphabetically
    sorted = @entries.sort_by { |e| e[:name] }

    # Calculate max width for alignment (include "Introduction")
    all_names = ["Introduction"] + sorted.map { |e| e[:name] }
    max_width = all_names.map(&:length).max

    # Generate 4-column layout with Introduction first
    cols = 4

    # First row starts with Introduction
    first_row = [{ name: "Introduction" }] + sorted[0..2]
    lines << "  " + first_row.map { |e| format_menu_link(e[:name], max_width) }.join('  ')

    # Remaining rows
    sorted[3..].each_slice(cols) do |row|
      line = "  " + row.map { |e| format_menu_link(e[:name], max_width) }.join('  ')
      lines << line
    end

    lines.join("\n")
  end

  def format_menu_link(name, width)
    # Pad to consistent width
    padded = name.ljust(width)
    "@{\" #{padded} \" link \"#{name}\"}"
  end

  def generate_index
    lines = []

    # Group by first letter
    sorted = @entries.sort_by { |e| e[:name] }
    current_letter = nil

    # Calculate max width for alignment
    max_width = sorted.map { |e| e[:name].length }.max

    sorted.each do |entry|
      letter = entry[:name][0].upcase
      if letter != current_letter
        lines << '' if current_letter  # blank line between groups
        lines << "        #{letter}"
        lines << ''
        current_letter = letter
      end
      lines << "        @{\" #{entry[:name].ljust(max_width)} \" link \"#{entry[:name]}\"}"
    end

    lines.join("\n")
  end
end

class AceConverter
  def initialize(content)
    @content = content
    @sections = []
  end

  def parse
    lines = @content.split("\n")

    # Find sections by looking for underlined headers
    # Pattern: text line followed by line of dashes
    current_section = nil
    section_content = []

    i = 0
    while i < lines.length
      line = lines[i]
      next_line = lines[i + 1]

      # Check if this line is a header (next line is dashes)
      if next_line && next_line.match?(/^-{3,}$/) && line.strip.length > 0
        # Save previous section
        if current_section
          @sections << {
            name: current_section,
            content: section_content.join("\n")
          }
        end

        current_section = line.strip
        section_content = []
        i += 2  # Skip the underline
        next
      end

      # Skip page markers
      unless line.match?(/^\s*- page \d+ -\s*$/)
        section_content << line
      end

      i += 1
    end

    # Save last section
    if current_section
      @sections << {
        name: current_section,
        content: section_content.join("\n")
      }
    end
  end

  def generate_guide
    output = []

    # Header
    output << '@DATABASE "ACEReference.doc"'
    output << '@MASTER "ACEReference"'
    output << ''

    # Main menu
    output << '@NODE MAIN "Main Menu"'
    output << ''
    output << '			       +----------+'
    output << '			       | ACE v2.5 |'
    output << '			       +----------+'
    output << ''

    # Calculate max width for alignment
    max_width = @sections.map { |s| s[:name].length }.max

    # Group sections into categories based on TOC structure
    # This is a simplified version - the full one would parse the TOC
    @sections.each do |section|
      node_name = section[:name].downcase.gsub(/[^a-z0-9]+/, '-')
      output << "                      @{\" #{section[:name].ljust(max_width)} \" link #{node_name}}"
    end

    output << '@ENDNODE'

    # Section nodes
    @sections.each do |section|
      node_name = section[:name].downcase.gsub(/[^a-z0-9]+/, '-')
      output << "@NODE #{node_name} \"#{section[:name]}\""
      output << section[:name]
      output << '-' * section[:name].length
      output << section[:content]
      output << '@ENDNODE'
    end

    output.join("\n")
  end
end

# Main
if ARGV.empty?
  puts "Usage: #{$0} <input.txt>"
  puts ""
  puts "Converts ACE documentation text files to AmigaGuide format."
  puts "  ref.txt -> ref.guide format"
  puts "  ace.txt -> ACE.guide format"
  exit 1
end

input_file = ARGV[0]
content = File.read(input_file)

if input_file.downcase.include?('ref')
  converter = RefConverter.new(content)
  converter.parse
  puts converter.generate_guide
else
  converter = AceConverter.new(content)
  converter.parse
  puts converter.generate_guide
end
