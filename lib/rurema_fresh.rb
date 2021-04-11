# frozen_string_literal: true

require_relative "rurema_fresh/version"

module RuremaFresh
  class Error < StandardError; end

  def self.remove_old_version(file_text, support_version)
    blocks = []
    delete_mode = false
    texts = file_text.lines
    texts.each do |text|
      if text.start_with?('#@since ') || text.start_with?('#@until ')
        blocks << text.dup
        version = text.split[1]
        if version <= support_version
          delete_mode = true if text.start_with?('#@until ')
          text.clear
        end
      elsif text.start_with?('#@else')
        directive, version = blocks.pop.split
        if version <= support_version
          text.clear
          delete_mode = (directive == '#@since')
        end
        directive_swap(directive)
        blocks << [directive, version].join(' ')
      elsif text.start_with?('#@end')
        directive, version = blocks.pop.split
        if (directive == '#@since' || directive == '#@until') && version <= support_version
          text.clear
          delete_mode = false
        elsif directive == '#@samplecode' && delete_mode
          text.clear
        end
      elsif text.start_with?('#@samplecode')
        blocks << text.dup
        text.clear if delete_mode
      else
        text.clear if delete_mode
      end
    end

    texts.join
  end

  def self.main
    file_path = ARGV.shift
    buffer = IO.read(file_path)
    puts buffer.lines[0, 4]
    buffer = remove_old_version(buffer, '2.4.0')
    IO.write(file_path, buffer)
  end

  private
    def self.directive_swap(directive)
      raise ArgumentError unless directive == '#@since' || directive == '#@until'
      directive.sub!('#@since', '#@_____')
      directive.sub!('#@until', '#@since')
      directive.sub!('#@_____', '#@until')
    end
end
