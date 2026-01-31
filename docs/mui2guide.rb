#!/usr/bin/env ruby
# mui2guide.rb - Convert MUI-Submod.txt to AmigaGuide format
#
# Usage:
#   ruby mui2guide.rb MUI-Submod.txt > MUI-Submod.guide

class MUIGuideConverter
  SECTION_SEPARATOR = /^={10,}$/

  def initialize(content)
    @content = content
    @sections = []
    @title = ""
    @version = ""
  end

  def parse
    lines = @content.split("\n")

    # Extract header (before first section)
    header_lines = []
    i = 0
    while i < lines.length && !lines[i].match?(SECTION_SEPARATOR)
      header_lines << lines[i]
      i += 1
    end

    # Parse title from header
    header_lines.each do |line|
      if line.include?("|") && line.include?("MUI")
        @title = line.gsub(/[|+\-]/, '').strip
      end
    end
    @title = "MUI Submod for ACE Basic" if @title.empty?

    # Skip first separator
    i += 1 if i < lines.length && lines[i].match?(SECTION_SEPARATOR)

    # Parse sections
    current_section = nil
    section_content = []

    while i < lines.length
      line = lines[i]

      if line.match?(SECTION_SEPARATOR)
        # Save previous section
        if current_section
          @sections << {
            name: current_section,
            content: section_content.join("\n").strip
          }
        end

        # Next line is section title
        i += 1
        if i < lines.length
          current_section = lines[i].strip
          section_content = []
        end

        # Skip closing separator
        i += 1
        i += 1 if i < lines.length && lines[i].match?(SECTION_SEPARATOR)
        next
      end

      section_content << line
      i += 1
    end

    # Save last section
    if current_section
      @sections << {
        name: current_section,
        content: section_content.join("\n").strip
      }
    end

    # Filter out empty or meta sections
    @sections.reject! do |s|
      s[:name].empty? ||
      s[:name] =~ /TABLE OF CONTENTS/i ||
      s[:name] =~ /END OF DOCUMENT/i ||
      s[:content].strip.empty?
    end
  end

  def node_name(section_name)
    # Convert section name to valid node name
    name = section_name.gsub(/[^A-Za-z0-9\s]/, '').strip
    name.downcase.gsub(/\s+/, '-')
  end

  def escape_amigaguide(text)
    # Escape @ signs that aren't part of AmigaGuide commands
    text.gsub(/@(?![{"])/, '@@')
  end

  def convert_links(text)
    # Convert section references like "see Section 5.1" to links
    result = text.dup

    # Link to numbered sections
    result.gsub!(/\b(Section\s+)(\d+\.\d+)/) do |match|
      prefix = $1
      section_num = $2
      # Find matching section
      target = @sections.find { |s| s[:name].start_with?(section_num) }
      if target
        "#{prefix}@{\"#{section_num}\" link \"#{node_name(target[:name])}\"}"
      else
        match
      end
    end

    result
  end

  def generate_guide
    output = []

    # Header
    output << '@DATABASE "MUI-Submod.doc"'
    output << '@MASTER "MUI-Submod"'
    output << ''

    # Main menu node
    output << '@NODE MAIN "MUI Submod - Main Menu"'
    output << ''
    output << '                        +----------------------+'
    output << '                        | MUI Submod for ACE   |'
    output << '                        | Programmer\'s Guide   |'
    output << '                        +----------------------+'
    output << ''
    output << '                              Version 1.0'
    output << ''

    # Calculate max width for alignment
    max_width = @sections.map { |s| s[:name].length }.max
    max_width = [max_width, 40].min  # Cap at 40 chars

    # Generate menu links
    @sections.each do |section|
      display_name = section[:name][0, 40]
      output << "  @{\" #{display_name.ljust(max_width)} \" link \"#{node_name(section[:name])}\"}"
    end

    output << ''
    output << '@ENDNODE'

    # Section nodes
    @sections.each do |section|
      output << ''
      output << "@NODE \"#{node_name(section[:name])}\" \"#{section[:name]}\""
      output << ''
      output << section[:name]
      output << '=' * section[:name].length
      output << ''
      output << escape_amigaguide(section[:content])
      output << ''
      output << '@ENDNODE'
    end

    output.join("\n")
  end
end

# Main
if ARGV.empty?
  puts "Usage: #{$0} MUI-Submod.txt > MUI-Submod.guide"
  puts ""
  puts "Converts MUI-Submod.txt to AmigaGuide format."
  exit 1
end

input_file = ARGV[0]
content = File.read(input_file)

converter = MUIGuideConverter.new(content)
converter.parse
puts converter.generate_guide
