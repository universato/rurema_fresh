# frozen_string_literal: true

require 'csv'
require_relative "./test_helper.rb"

# もともとCSVで、対象の文字列と実行結果をいれてましたが、
# GitHubのCSVはセル内の改行に対応してないのでやめました。

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

  def test_remove_old_since1
    src = <<-'TEXT'
#@since 1.8.7
残る
#@end
    TEXT

    assert_equal "残る\n", RuremaFresh.remove_old_version(src, '2.4.0')
    assert_equal "残る\n", RuremaFresh.remove_old_version(src, '2.4')
    assert_equal "残る\n", RuremaFresh.remove_old_version(src, 2.4)
  end

  def test_remove_old_since2
    src = <<-'TEXT'
残る
#@since 2.4.0
残る
#@end
残る
    TEXT

    assert_equal "残る\n" * 3, RuremaFresh.remove_old_version(src, '2.4.0')
    assert_equal "残る\n" * 3, RuremaFresh.remove_old_version(src, '2.4')
    assert_equal "残る\n" * 3, RuremaFresh.remove_old_version(src, 2.4)
  end

  def test_remove_old_until1
    src = <<-'TEXT'
残る
#@until 1.8.7
残らない
#@end
残る
    TEXT

    assert_equal "残る\n" * 2, RuremaFresh.remove_old_version(src, '2.4.0')
    assert_equal "残る\n" * 2, RuremaFresh.remove_old_version(src, '2.4')
    assert_equal "残る\n" * 2, RuremaFresh.remove_old_version(src, 2.4)
  end

  def test_remove_old_until2
    src = <<-'TEXT'
#@until 2.4.0
残らない
#@end
    TEXT
    assert_equal "", RuremaFresh.remove_old_version(src, '2.4.0')
    assert_equal "", RuremaFresh.remove_old_version(src, '2.4')
    assert_equal "", RuremaFresh.remove_old_version(src, 2.4)
  end

  def test_remove_old_since_and_else1
    src = <<-'TEXT'
残る
#@since 1.8.7
残る
#@else
残らない
#@end
残る
    TEXT
    assert_equal "残る\n" * 3, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_since_and_else2
    src = <<-'TEXT'
#@since 2.4.0
残る
#@else
残らない
#@end
    TEXT
    assert_equal "残る\n", RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_until_and_else1
    src = <<-'TEXT'
#@until 1.8.7
残らない
#@else
残る
#@end
    TEXT
    assert_equal "残る\n", RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_until_and_else2
    src = <<-'TEXT'
#@until 2.4.0
残らない
#@else
残る
#@end
    TEXT
    assert_equal "残る\n", RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_fresh_since
    dst = src = <<-'TEXT'
#@since 3.1.0
条件分岐の分岐地点が新しいので全て残ります。
#@else
条件分岐の分岐地点が新しいので全て残ります。
#@end
    TEXT

    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_until_since
    dst = src = <<-'TEXT'
#@until 3.1.0
条件分岐の分岐地点が新しいので全て残ります。
#@else
条件分岐の分岐地点が新しいので全て残ります。
#@end
    TEXT

    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_since_in_samplecode1
    src = <<-'TEXT'
#@samplecode
#@since 1.8.7
残る
#@else
残らない
#@end
#@end
    TEXT

    dst = <<-'TEXT'
#@samplecode
残る
#@end
    TEXT
    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_until_in_samplecode1
    src = <<-'TEXT'
#@samplecode
#@until 1.8.7
残らない
#@else
残る
#@end
#@end
    TEXT

    dst = <<-'TEXT'
#@samplecode
残る
#@end
    TEXT
    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4.0')
    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4')
    assert_equal dst, RuremaFresh.remove_old_version(src, 2.4)
  end

  def test_remove_old_until_in_samplecode2
    src = <<-'TEXT'
#@samplecode
残る
#@until 2.4.0
残らない
#@else
残る
#@end
#@end
    TEXT

    dst = <<-'TEXT'
#@samplecode
残る
残る
#@end
    TEXT
    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_since_with_comment
    src = <<-'TEXT'
#@since 1.8.0
#@# 残るコメント
#@else
#@# 残らないコメント
#@end
    TEXT
    assert_equal "#@# 残るコメント\n", RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_since_in_since_in_since
    src = <<-'TEXT'
残る
#@since 1.8.0
残る
#@since 2.0.0
残る
#@since 2.4.0
#@end
残る
#@end
残る
#@else
1.8.0未満で、残らない
#@end
残る
    TEXT
    assert_equal "残る\n" * 6, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_until_in_until
    src = <<-'TEXT'
#@until 2.0.0
残らない
#@until 1.8.7
残らない
#@end
残らない
#@until 2.4.0
残らない
#@end
残らない
#@else
残る
#@end
残る
    TEXT
    assert_equal "残る\n" * 2, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_until_in_until2
    src = <<-'TEXT'
#@until 2.0.0
残らない
#@until 1.8.7
残らない
#@end
残らない
#@until 2.4.0
残らない
#@end
残らない
#@end
残る
    TEXT
    assert_equal "残る\n" * 1, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_old_since_in_until
    src = <<-'TEXT'
外だから残る
#@until 1.9.2
#@# 残らない1
#@since 1.9.1
残らない2
#@else
残らない3
#@end
残らない4
#@end
外だから残る
    TEXT
    assert_equal "外だから残る\n" * 2, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_fresh_since_in_old_until1
    # 古い条件分岐の中にそれより新しい条件分岐があるという誤った条件分岐
    # skip
    ___src = <<-'TEXT'
外だから残る
#@until 1.9.2
#@since 3.3.0
残らない
#@else
残らない
#@end
#@end
外だから残る
    TEXT
    # assert_equal "外だから残る\n" * 2, RuremaFresh.remove_old_version(src, '2.4.0')
  end

  def test_remove_fresh_until_in_old_until
    src = <<-'TEXT'
外だから残る
#@since 3.0.0
#@until 1.8.7
残らない
#@else
残る
#@end
#@end
外だから残る
    TEXT

    dst = <<-'TEXT'
外だから残る
#@since 3.0.0
残る
#@end
外だから残る
    TEXT
    assert_equal dst, RuremaFresh.remove_old_version(src, '2.4.0')
  end
end
