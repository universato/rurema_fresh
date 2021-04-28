# frozen_string_literal: true

require_relative "./rurema_fresh/option.rb"
require_relative "./rurema_fresh/version.rb"

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

# For debug
if $0 == __FILE__
  # puts "#{__FILE__}が直接実行されました。"
  # text =  DATA.readlines.join
  # puts RuremaFresh.remove_old_version(text, "2.4.0")
end

__END__
#@samplecode
#@since 1.9.0
# 0番目の文字を返す
p "abc"[0] #=> "a"
#@else
# 0番目の文字コードを返す
p "abc"[0] #=> 97
#@end
#@end
