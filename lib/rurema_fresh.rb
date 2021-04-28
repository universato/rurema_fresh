# frozen_string_literal: true

require_relative "./rurema_fresh/constants.rb"
require_relative "./rurema_fresh/option.rb"
require_relative "./rurema_fresh/version.rb"

module RuremaFresh
  class Error < StandardError; end

  def self.remove_old_version(file_text, support_version = DEFAULT_SUPPORT_VERSION)
    support_version = add_minor(support_version)

    blocks = []
    delete_mode = false

    file_text = file_text.gsub(/^\#@if\s*\(\s*version\s*([<>!=]=?)\s*["'](.+)["']\s*\)/){
      op = $1
      version = $2
      if op.include?('<')
        if op.include?('=')
          # puts "RuremaFresh Alert: if (version <= #{version}) を無理やり書きかえます。"
          # puts "-> \#@until #{version.succ} に書き換えます。"
          "\#@until #{version.succ}"
        else
          "\#@until #{version}"
        end
      elsif op.include?('>')
        if op.include?('=')
          "\#@since #{version}"
        else
          # puts "RuremaFresh Alert: if (version > #{version})  を無理やり書きかえます。"
          # puts "-> \#@since #{version.succ} に書き換えます。"
          "\#@since #{version.succ}"
        end
      elsif op == "=="
        if version < support_version
          "\#@until #{version.succ}"
        else
          puts "RuremaFresh versionがサポートしてないif == です。変更せず終了します。"
        end
      elsif op == "!="
        if version < support_version
          "\#@since #{version}"
        else
          puts "RuremaFresh versionがサポートしてないif != です。変更せず終了します。"
        end
      else
        puts "RuremaFresh #{__FILE__}: #{__LINE__}行目:"
        puts "本来、ここは実行されません。異常終了します。"
        exit
      end
    }

    texts = file_text.lines
    texts.each_with_index do |text, line_no|
      if text.start_with?('#@if')
        puts "#{line_no + 1}行目に、\#@ifを検知しました・"
        puts 'rurema_freshは全てのifをサポートしてないので終了します。サポートしたいけど、未定。'
        exit
        # [DRAFT][WIP][TODO]
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
  class << self
    alias version remove_old_version
  end

  private
    # module RuremaFresh
    #   directive = '#@since 2.4.0'
    #   RuremaFresh.directive_swap(directive)
    #   p directive  # => '#@until 2.4.0'
    #   RuremaFresh.directive_swap(directive)
    #   p directive # =>  '#@since 2.4.0'
    # end
    def self.directive_swap(directive)
      raise ArgumentError unless directive == '#@since' || directive == '#@until'
      directive.sub!('#@since', '#@_____')
      directive.sub!('#@until', '#@since')
      directive.sub!('#@_____', '#@until')
    end

    # module RuremaFresh
    #   self.add_minor(0)     # => "0.0.0"
    #   self.add_minor(2)     # => "2.0.0"
    #   self.add_minor("2")   # => "2.0.0"
    #   self.add_minor(2.4)   # => "2.4.0"
    #   self.add_minor("2.4") # => "2.4.0"
    # end
    def self.add_minor(version)
      version = version.to_s
      if Gem::Version.correct?(version)
        case version.count(".")
        when 0
          version + ".0.0"
        when 1
          version + ".0"
        else
          version
        end
      else
        puts "#{__FILE__}: #{__LINE__}行目でエラーが生じました。"
        puts "rurema_fresh: 不正なバージョン入力です。終了します。"
        exit
      end
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
