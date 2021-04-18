# frozen_string_literal: true

require 'csv'
require_relative "./test_helper.rb"

class RuremaFreshTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RuremaFresh::VERSION
  end

  csv_path = File.expand_path('../testcases.csv', __FILE__)
  CSV.foreach(csv_path, headers: true).with_index(1) do |row, i|
    if row['support_version'].nil?
      puts "#{i}行目のテストケースにサポートしたいバージョンがありません。テストを終了します。"
      exit
    end

    str = "def test_remove#{i}
            #{'skip' if row['skip']}
            assert_equal '#{row['target']}', RuremaFresh.remove_old_version('#{row['src']}', '#{row['support_version']}')
          end"
    class_eval(str)
  end
end
