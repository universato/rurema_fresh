require 'optparse'

module RuremaFresh
  def self.options
    opt = OptionParser.new
    opt.version = RuremaFresh::VERSION
    opt.banner         = "Usage: rurema_fresh version ./rurema_file [--ruby=#{DEFAULT_SUPPORT_VERSION}]"
    opt.summary_width  = 14
    opt.summary_indent = ' ' * 4
    opt.default_argv   = ARGV
    opt.on('-r:', '--ruby', 'Ruby support version。サポートしたいRubyバージョン。')
    opt.on_tail('-h', '--help', 'show this help') { puts opt.help and exit }

    opt.getopts
  end
end
