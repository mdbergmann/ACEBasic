#!/usr/bin/env ruby
# txt2guide.rb - Convert ACE documentation text files to AmigaGuide format
#
# Usage:
#   ruby txt2guide.rb ref.txt > ref.guide
#   ruby txt2guide.rb ace.txt > ACE.guide
#   ruby txt2guide.rb MUI-Submod.txt > MUI-Submod.guide
#
# =============================================================================
# TEXT FILE CONVENTIONS
# =============================================================================
#
# Two document types are supported:
#
# 1. COMMAND REFERENCE (ref.txt)
#    - 80-dash lines separate command entries
#    - Each entry becomes a separate AmigaGuide node
#    - First line of entry is the command name
#
#    Example:
#      --------------------------------------------------------------------------------
#      PRINT    - syntax: PRINT [expression]
#               - Outputs text to the current window.
#      --------------------------------------------------------------------------------
#      INPUT    - syntax: INPUT [prompt;] variable
#               - Reads user input.
#
# 2. MANUAL-STYLE (ace.txt, MUI-Submod.txt)
#    Uses two types of markers:
#
#    a) SECTION HEADER (creates new AmigaGuide node):
#       - Title line followed by dashes as underline
#       - Underline length should be similar to title length (< 70 chars)
#
#       Example:
#         4. Concepts
#         -----------
#
#    b) SUBSECTION SEPARATOR (stays within current node):
#       - 80-dash lines surround subsection title
#       - Content remains part of parent section
#
#       Example:
#         --------------------------------------------------------------------------------
#         4.1 The Object Tree
#         --------------------------------------------------------------------------------
#
#         Every MUI application is a tree of objects...
#
# The distinction between underline and separator:
#   - Underline: < 70 dashes, length close to title (within 10 chars)
#   - Separator: exactly 80 dashes, used for visual separation within sections
#
# =============================================================================

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

# Base class for manual-style documents (underlined section headers)
class ManualConverter
  def initialize(content)
    @content = content
    @sections = []
  end

  def parse
    lines = @content.split("\n")

    # Find sections by looking for underlined headers
    # Pattern: text line followed by line of dashes (underline, not separator)
    # An underline has similar length to the title (within margin)
    # A separator is exactly 80 dashes
    current_section = nil
    section_content = []

    i = 0
    while i < lines.length
      line = lines[i]
      next_line = lines[i + 1]

      # Check if this line is a header (next line is underline dashes)
      # Underline: dashes with length close to title length (not 80-char separator)
      if next_line && next_line.match?(/^-{3,}$/) && line.strip.length > 0
        dash_len = next_line.length
        title_len = line.strip.length

        # It's an underline if dashes are roughly same length as title
        # 80-dash lines are separators, not underlines
        is_underline = dash_len < 70 && (dash_len - title_len).abs < 10

        if is_underline
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

  def escape_amigaguide(text)
    # In AmigaGuide, only @{ and @" start commands
    # Standalone @ (like BASIC's address operator) is fine
    text
  end
end

class AceConverter < ManualConverter
  def generate_guide
    output = []

    # Header
    output << '@DATABASE "ACEReference.doc"'
    output << '@MASTER "ACEReference"'
    output << ''

    # Main menu
    output << '@NODE MAIN "Main Menu"'
    output << ''
    output << '			       +------------+'
    output << '			       | ACE v2.9.0 |'
    output << '			       +------------+'
    output << ''

    # Calculate max width for alignment
    max_width = @sections.map { |s| s[:name].length }.max || 20

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
      output << escape_amigaguide(section[:content])
      output << '@ENDNODE'
    end

    output.join("\n")
  end
end

class MUIConverter < ManualConverter
  def generate_guide
    output = []

    # Header
    output << '@DATABASE "MUI-Submod.doc"'
    output << '@MASTER "MUI-Submod"'
    output << ''

    # Main menu
    output << '@NODE MAIN "MUI Submod - Main Menu"'
    output << ''
    output << '                        +----------------------+'
    output << '                        | MUI Submod for ACE   |'
    output << "                        | Programmer's Guide   |"
    output << '                        +----------------------+'
    output << ''
    output << '                              Version 1.0'
    output << ''
    output << '            Copyright (c) 2026 Manfred Bergmann. All rights reserved.'
    output << ''

    # Only show main sections in menu (skip TOC and subsections)
    # Main sections match: "1. Name" but not "1.1 Name"
    main_sections = @sections.select { |s| s[:name].match?(/^\d+\.\s+[A-Z]/) }

    max_width = [main_sections.map { |s| s[:name].length }.max || 20, 30].min

    main_sections.each do |section|
      display_name = section[:name].upcase[0, 30]
      node_name = section[:name].downcase.gsub(/[^a-z0-9]+/, '-')
      output << "  @{\" #{display_name.ljust(max_width)} \" link \"#{node_name}\"}"
    end

    output << ''
    output << '@ENDNODE'

    # Section nodes - all sections, not just main ones
    # Skip TOC section
    content_sections = @sections.reject { |s| s[:name] =~ /TABLE OF CONTENTS/i }

    content_sections.each do |section|
      node_name = section[:name].downcase.gsub(/[^a-z0-9]+/, '-')
      output << ''
      output << "@NODE \"#{node_name}\" \"#{section[:name].upcase}\""
      output << ''
      output << section[:name].upcase
      output << '=' * section[:name].length
      output << ''
      output << escape_amigaguide(section[:content])
      output << ''
      output << '@ENDNODE'
    end

    output.join("\n")
  end
end

# Detect file format based on filename and content
def detect_format(filename, content)
  # MUI documentation
  if filename.downcase.include?('mui')
    return :mui
  end

  lines = content.split("\n")

  # ref.txt uses 80-dash separators frequently as entry separators
  dash_separator_count = lines.count { |l| l == "-" * 80 }
  if dash_separator_count > 5
    return :ref
  end

  # Default to ace.txt format (underlined sections)
  :ace
end

# Main
if ARGV.empty?
  puts "Usage: #{$0} <input.txt>"
  puts ""
  puts "Converts ACE documentation text files to AmigaGuide format."
  puts "  ref.txt        - Command reference (80-dash separators)"
  puts "  ace.txt        - ACE user manual (underlined headers)"
  puts "  MUI-Submod.txt - MUI guide (underlined headers)"
  exit 1
end

input_file = ARGV[0]
content = File.read(input_file)
format = detect_format(input_file, content)

case format
when :ref
  converter = RefConverter.new(content)
  converter.parse
  puts converter.generate_guide
when :mui
  converter = MUIConverter.new(content)
  converter.parse
  puts converter.generate_guide
else
  converter = AceConverter.new(content)
  converter.parse
  puts converter.generate_guide
end
