# frozen_string_literal: true

require_relative "./rurema_fresh/constants.rb"
require_relative "./rurema_fresh/option.rb"
require_relative "./rurema_fresh/version.rb"

module RuremaFresh
  class Error < StandardError; end

  def self.remove_old_versions(file_text, support_version = DEFAULT_SUPPORT_VERSION)
    support_version = add_minor(support_version)

    blocks = []
    delete_mode = false

    file_text = self.replace_if(file_text, support_version)

    texts = file_text.lines
    texts.each_with_index do |text, line_no|
      if text.start_with?('#@since ', '#@until ')
        blocks << text.dup
        version = text.split[1]
        if version <= support_version
          delete_mode = true if text.start_with?('#@until ')
          text.clear
        end
      elsif text.start_with?('#@else')
        next if blocks[-1].start_with?('#@if')
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
        elsif (directive == '#@samplecode' || directive == '#@if') && delete_mode
          text.clear
        end

        if (directive, version = blocks.last&.split)
          if directive == '#@until' && version <= support_version
            delete_mode = true
          end
        end
      elsif text.start_with?('#@samplecode', '#@if')
        blocks << text.dup
        text.clear if delete_mode
      else
        text.clear if delete_mode
      end
    end

    texts.join
  end
  class << self
    alias versions remove_old_versions
  end

  def self.replace_if(text, support_version)
    text.gsub(/^(\#@if\s*\(\s*version\s*([<>!=]=?)\s*["'](.+)["']\s*\))/){
      zentai = $1
      op = $2
      version = $3
      if op.include?('<')
        if op.include?('=')
          "\#@until #{self.ruby_advance(version)}"
        else
          "\#@until #{version}"
        end
      elsif op.include?('>')
        if op.include?('=')
          "\#@since #{version}"
        else
          "\#@since #{self.ruby_advance(version)}"
        end
      elsif op == "=="
        if version < support_version
          "\#@until #{self.ruby_advance(version)}"
        else
          zentai.sub('#@if(', '#@if (')
        end
      elsif op == "!="
        if version < support_version
          "\#@since #{version}"
        else
          zentai.sub('#@if(', '#@if (')
        end
      else
        puts "RuremaFresh #{__FILE__}: #{__LINE__}行目:"
        puts "本来、ここは実行されないはずです。異常終了します。"
        exit
      end
    }.gsub(/^(\#@if\s*\(\s*["'](.+)["']\s*(<=?)\s*version\s+and\s+version\s*(<=?)\s*["'](.+)["']\s*\))/){

      zentai = $1
      version1 = $2
      _op = $3
      op = $4
      version2 = $5

      if version1 < support_version
        if op.include?('=')
          "\#@until #{self.ruby_advance(version2)}"
        else
          "\#@until #{version2}"
        end
      else
        zentai.sub('#@if(', '#@if (')
      end
    }
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
      raise ArgumentError.new('引数は、#@since or #@until のみです') unless directive == '#@since' || directive == '#@until'
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
        puts "RuremaFresh: #{__FILE__}:#{__LINE__}行目でエラーが生じました。"
        puts "#{version}: 不正なバージョン入力です。終了します。"
        exit
      end
    end

    # module RuremaFresh
    #   self.advance("1.8.7") # => "1.9.0"
    #   self.advance("1.9.1") # => "2.0.0"
    #   self.advance("2.0.0") # => "2.1.0"
    #   self.advance("2.4.0") # => "2.5.0"
    #   self.advance("2.7.0") # => "3.0.0"
    # end
    def self.ruby_advance(version)
      version = Gem::Version.new(version).bump.version
      self.add_minor(version).gsub("2.8.0", "3.0.0")
    end
end


# For debug
if $0 == __FILE__
  # puts "#{__FILE__}が直接実行されました。"
  # text =  DATA.readlines.join
  # puts RuremaFresh.remove_old_versions(text, "2.4.0")
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
