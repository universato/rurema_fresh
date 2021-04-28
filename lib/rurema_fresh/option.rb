require 'optparse'

module RuremaFresh
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
end
