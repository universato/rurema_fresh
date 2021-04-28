# frozen_string_literal: true

require 'optparse'
require_relative "rurema_fresh/version"

module RuremaFresh
  class Error < StandardError; end

  def self.remove_old_version(file_text, support_version)
    blocks = []
    delete_mode = false
    texts = file_text.lines
    texts.each_with_index do |text, line_no|
      if text.start_with?('#@if')
        puts '#@ifを検知しましたが、rurema_freshはサポートしてないので終了します。サポートしたいけど、未定。'
        exit
        # [DRAFT]
        # if text.include?('>') && !text.include?('<')
        #   text.gsub!(/\#@if\s*\(\s*version\s*>=\s*(.+)\)/){ '#@since ' + $1 }
        # elsif text.include?('<') && !text.include?('>') && !text.include?('<=')
        #   text.gsub!(/\#@if\s*\(\s*version\s*>=\s*(.+)\)/){ '#@until ' + $1 }
        # end
      end

      if text.start_with?('#@since ', '#@until ')
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

        if (directive, version = blocks.last&.split)
          if directive == '#@until' && version <= support_version
            delete_mode = true
          end
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

  OPTION_EXPLANATIONS = {
    '--ruby:' => 'Ruby support version; サポートしたいRubyバージョン;'
  }.freeze

  # [TODO][WIP]
  def self.options
    opt = OptionParser.new
    opt.banner         = 'Usage: rurema_fresh [--ruby]'
    opt.summary_width  = 14
    opt.summary_indent = ' ' * 4
    opt.default_argv   = ARGV
    # OPTION_EXPLANATIONS.each { |option, explanation| opt.on(option, explanation) }
    opt.on('-r:', '--ruby', 'Ruby support version; サポートしたいRubyバージョン;')
    opt.on_tail('-h', '--help', 'show this help') { puts opt.help and exit }

    opt.getopts
  end

  def self.main(support_version = '2.4.0')
    file_path = ARGV.shift
    buffer = IO.read(file_path)
    puts buffer.lines[0, 4]
    buffer = RuremaFresh.remove_old_version(buffer, support_version)
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

if $0 == __FILE__
  puts "#{__FILE__}が直接実行されました。"
  text =  DATA.readlines.join
  puts RuremaFresh.remove_old_version(text, "2.4.0")
end

__END__
#@until 1.9.2
#@# 残らない1
#@since 1.9.1
残らない2
#@else
残らない3
#@end
残らない4
#@end
残る
