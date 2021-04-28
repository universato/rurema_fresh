require 'optparse'

module RuremaFresh
  def self.options
    options = {}

    opt = OptionParser.new
    opt.version = RuremaFresh::VERSION
    opt.banner         = "Usage: rurema_fresh version ./rurema_file [--ruby=#{DEFAULT_SUPPORT_VERSION}]"
    opt.summary_width  = 14
    opt.summary_indent = ' ' * 4
    opt.on('-r:', '--ruby', 'Ruby support version。サポートしたいRubyバージョン。'){ |version|
      options[:ruby] = version
    }
    opt.on_tail('-h', '--help', 'show this help') { puts opt.help and exit }

    begin
      opt.parse!(ARGV)
    rescue OptionParser::InvalidOption => e
      puts e.inspect
      puts "RuremaFresh: サポートしてないオプションが入力されました"
    end

    options
  end
end
