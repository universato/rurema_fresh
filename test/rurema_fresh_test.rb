# frozen_string_literal: true

require 'csv'
require_relative "./test_helper.rb"

class RuremaFreshTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RuremaFresh::VERSION
  end

  # もともとCSVで、対象の文字列と実行結果をいれてましたが、
  # GitHubのCSVはセル内の改行に対応してないのでやめました。
  csv_path = File.expand_path('../testcases.csv', __FILE__)
  CSV.foreach(csv_path, headers: true).with_index(1) do |row, i|
    if row['support_version'].nil?
      puts "#{i}行目のテストケースにサポートしたいバージョンがありません。テストを終了します。"
      exit
    end

    str = "def test_remove#{i}
            #{'skip' if row['skip']}
            assert_equal '#{row['target']}', RuremaFresh.remove_old_versions('#{row['src']}', '#{row['support_version']}')
          end"
    class_eval(str)
  end

  def test_sample
    src = <<-'TEXT'
#@since 3.0.0
3.0.0以上の環境で出力される
#@end
#@until 3.0.0
3.0.0未満の環境で出力される
#@end
    TEXT

    dst = "3.0.0以上の環境で出力される\n"
    assert_equal dst, RuremaFresh.remove_old_versions(src, '3.0.0')
    assert_equal dst, RuremaFresh.remove_old_versions(src, '3.0')
    assert_equal dst, RuremaFresh.remove_old_versions(src, 3.0)
    assert_equal dst, RuremaFresh.remove_old_versions(src, '3')
    assert_equal dst, RuremaFresh.remove_old_versions(src, 3)
  end

  def test_remove_old_since1
    src = <<-'TEXT'
#@since 1.8.7
残る
#@end
    TEXT

    assert_equal "残る\n", RuremaFresh.remove_old_versions(src, '2.4.0')
    assert_equal "残る\n", RuremaFresh.remove_old_versions(src, '2.4')
    assert_equal "残る\n", RuremaFresh.remove_old_versions(src, 2.4)
  end

  def test_remove_old_since2
    src = <<-'TEXT'
残る
#@since 2.4.0
残る
#@end
残る
    TEXT

    assert_equal "残る\n" * 3, RuremaFresh.remove_old_versions(src, '2.4.0')
    assert_equal "残る\n" * 3, RuremaFresh.remove_old_versions(src, '2.4')
    assert_equal "残る\n" * 3, RuremaFresh.remove_old_versions(src, 2.4)
  end

  def test_remove_old_until1
    src = <<-'TEXT'
残る
#@until 1.8.7
残らない
@see [[m:Kernel.#puts]]
#@end
残る
    TEXT

    assert_equal "残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4.0')
    assert_equal "残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4')
    assert_equal "残る\n" * 2, RuremaFresh.remove_old_versions(src, 2.4)
  end

  def test_remove_old_until2
    src = <<-'TEXT'
#@until 2.4.0
残らない
#@end
    TEXT
    assert_equal "", RuremaFresh.remove_old_versions(src, '2.4.0')
    assert_equal "", RuremaFresh.remove_old_versions(src, '2.4')
    assert_equal "", RuremaFresh.remove_old_versions(src, 2.4)
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
    assert_equal "残る\n" * 3, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_since_and_else2
    src = <<-'TEXT'
#@since 2.4.0
残る
#@else
残らない
#@end
    TEXT
    assert_equal "残る\n", RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_until_and_else1
    src = <<-'TEXT'
#@until 1.8.7
残らない
#@else
残る
#@end
    TEXT
    assert_equal "残る\n", RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_until_and_else2
    src = <<-'TEXT'
#@until 2.4.0
残らない
#@else
残る
#@end
    TEXT
    assert_equal "残る\n", RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_fresh_since
    dst = src = <<-'TEXT'
#@since 3.1.0
条件分岐の分岐地点が新しいので全て残ります。
#@else
条件分岐の分岐地点が新しいので全て残ります。
#@end
    TEXT

    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_until_since
    dst = src = <<-'TEXT'
#@until 3.1.0
条件分岐の分岐地点が新しいので全て残ります。
#@else
条件分岐の分岐地点が新しいので全て残ります。
#@end
    TEXT

    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
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
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
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
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4')
    assert_equal dst, RuremaFresh.remove_old_versions(src, 2.4)
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
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_since_with_comment
    src = <<-'TEXT'
#@since 1.8.0
#@# 残るコメント
#@else
#@# 残らないコメント
#@end
    TEXT
    assert_equal "#@# 残るコメント\n", RuremaFresh.remove_old_versions(src, '2.4.0')
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
    assert_equal "残る\n" * 6, RuremaFresh.remove_old_versions(src, '2.4.0')
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
    assert_equal "残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4.0')
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
    assert_equal "残る\n" * 1, RuremaFresh.remove_old_versions(src, '2.4.0')
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
    assert_equal "外だから残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_fresh_since_in_old_until1
    # 条件分岐の古いコードの中にそれより新しい条件分岐があるという誤った条件分岐
    # こういったケースでは、適切に削除できない。
    _src = <<-'TEXT'
#@until 1.9.2
#@since 3.3.0
残る
#@else
残らない
#@end
#@end
    TEXT

    _dst = <<-'TEXT'
#@since 3.3.0
#@else
#@end
    TEXT

    # assert_equal _dst, RuremaFresh.remove_old_versions(_src, '2.4.0')
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
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_if_until
    src = <<-'TEXT'
外だから残る
#@if (version < "1.9.4")
消える
#@end
外だから残る
    TEXT
    assert_equal "外だから残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_if_until2
    src = <<-'TEXT'
外だから残る
#@if (version < "2.4.0")
消える
#@end
外だから残る
    TEXT
    assert_equal "外だから残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_if_until3
    src = <<-'TEXT'
外だから残る
#@if (version <= "2.4.0")
残る
#@end
外だから残る
    TEXT

    dst = <<-'TEXT'
外だから残る
#@until 2.5.0
残る
#@end
外だから残る
    TEXT
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_fresh_if_since0
    src = <<-'TEXT'
外だから残る
#@if ( version >=  "2.4.0" )
条件分岐は消えるが、ここは残る
#@end
外だから残る
    TEXT

    dst = <<-'TEXT'
外だから残る
条件分岐は消えるが、ここは残る
外だから残る
    TEXT
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_fresh_if_since1
    src = <<-'TEXT'
外だから残る
#@if ( version >=  "4.0.0" )
残る
#@end
外だから残る
    TEXT

    dst = <<-'TEXT'
外だから残る
#@since 4.0.0
残る
#@end
外だから残る
    TEXT
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_fresh_if_since2
    src = <<-'TEXT'
外だから残る
#@if ( version >  "4.0.0" )
残る
#@end
外だから残る
    TEXT

    dst = <<-'TEXT'
外だから残る
#@since 4.1.0
残る
#@end
外だから残る
    TEXT
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_if_equal
    src = <<-'TEXT'
外だから残る
#@if(version=="1.0.0")
#@samplecode
条件分岐ごと消える
#@#コメントもコードも消える
#@end
#@end
外だから残る
    TEXT

    assert_equal "外だから残る\n" * 2, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_old_if_equal2
    src = <<-'TEXT'
外だから残る
#@if ( version ==  "2.4.0" )
残る
#@end
外だから残る
    TEXT
    assert_equal src, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_if_not_equal1
    src = <<-'TEXT'
残る
#@if ( version !=  "1.0.0" )
残る
#@end
残る
    TEXT

    assert_equal "残る\n" * 3, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_fresh_if_not_equal2
    src = <<-'TEXT'
残る
#@if ( version !=  "2.4.1" )
残る
#@end
残る
    TEXT

    assert_equal src, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_double_if
    src = <<-'TEXT'
残る
#@if ( "1.0.0" < version and version < "2.4.0"  )
#@samplecode
条件分岐ごと消える
#@end
#@else
残る
#@end
残る
  TEXT

    assert_equal "残る\n" * 3, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remove_old_if_and_fresh_if
    src = <<-'TEXT'
残る
#@if ( "1.0.0" < version and version < "2.7.0"  )
残る
#@else
残る
#@end
残る
  TEXT

    dst = <<-'TEXT'
残る
#@until 2.7.0
残る
#@else
残る
#@end
残る
      TEXT
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_fresh_double_if
    src = <<-'TEXT'
残る
#@if ( "3.0.0" < version and version < "3.1.0"  )
残る
#@else
残る
#@end
残る
  TEXT

    dst = <<-'TEXT'
残る
#@if ( "3.0.0" < version and version < "3.1.0"  )
残る
#@else
残る
#@end
残る
      TEXT
    assert_equal dst, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_fresh_if_equal
    src = <<-'TEXT'
残る
#@if (version=="3.1.0")
残る
#@samplecode
残る
#@end
残る
#@else
残る
#@samplecode
残る
#@end
残る
#@end
残る
  TEXT

    assert_equal src, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_fresh_if_not_equal
    src = <<-'TEXT'
残る
#@if ( version  !=  "3.1.0"  )
残る
#@else
残る
#@end
残る
  TEXT

    assert_equal src, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_reverse_if
    src = <<-'TEXT'
残る
#@if (   "3.1.0" > version )
#@if ( "2.7.0 > version ")
#@end
#@else
残る
#@end
残る
  TEXT

    assert_equal src, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_remain_reverse_duble_if
    src = <<-'TEXT'
残る
#@if ( version < 2.7.0 and version < 3.1.0)
残る
#@else
残る
#@end
残る
  TEXT

    assert_equal src, RuremaFresh.remove_old_versions(src, '2.4.0')
  end

  def test_reamain_support27
    src = <<-'TEXT'
#@if (3.1 <= version and version<3.3)
残る
#@since 3.0
残る
#@end
残る
#@since 3.2
残る
#@end
残る
#@else
残る
#@until 3.4
残る
#@# 残るコメント
#@samplecode
#@since 3.0
残る
#@end
#@end
残る
#@end
残る
#@end
  TEXT

    assert_equal src, RuremaFresh.remove_old_versions(src, '2.7.0')
    assert_equal src, RuremaFresh.remove_old_versions(src, 2.7)
  end

  def test_remove_support27
    src = <<-'TEXT'
#@if(version<'2.7.0')
#@#消えるコメント
#@end
#@if('1.8.7'<= version and version < '2.1')
条件とともに全て消える。
#@if(version != '1.9')
#@end
#@end
    TEXT

    assert_equal '', RuremaFresh.remove_old_versions(src, '2.7.0')
  end

  def test_remove_support27a
    src = <<-'TEXT'
#@until 2.1
条件とともに全て消える。
#@if(version != '1.9')
#@end
#@end
    TEXT

    assert_equal '', RuremaFresh.remove_old_versions(src, '2.7.0')
  end


  def test_change_support27
    src = <<-'TEXT'
#@if('1.8.7'<= version and version < '2.1')
条件とともに全て消える。
#@end
    TEXT

    assert_equal '', RuremaFresh.remove_old_versions(src, '2.7.0')
  end

  def test_delete_support3
    src = <<-'TEXT'
#@if('1.8.7'<= version and version < '2.1')
条件とともに全て消える。
#@end
#@until 3.0.0
消える
#@end
#@until 3.0
消える
#@end
#@until 3
消える
#@end
    TEXT

    assert_equal '', RuremaFresh.remove_old_versions(src, '3.0.0')
    assert_equal '', RuremaFresh.remove_old_versions(src, '3.0')
    assert_equal '', RuremaFresh.remove_old_versions(src, 3.0)
    assert_equal '', RuremaFresh.remove_old_versions(src, '3')
    assert_equal '', RuremaFresh.remove_old_versions(src, 3)
  end
end
