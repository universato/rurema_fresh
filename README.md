# RuremaFresh

RuremaFreshは、るりまの愛称で知られるRubyリファレンスマニュアルのrd形式の文書の整形・サポートを目的としたgemです。

なお、現在は、「古い条件分岐の削除、可能なら`if`を`since`や`until`に置き換える、メソッド・コマンド」のみを提供しています。

## Installation

主なインストール方法を紹介します。

- gemの`bundler`を用いてインストールする方法
  1. `Gemfile`に`gem 'rurema_fresh', :github => 'universato/rurema_fresh'`と書きます。
  2. コマンド`bundle install`で、Gemfile(& Gemfile.lock)に従って、インストール。
<!-- - コマンド`gem install rurema_fresh`を打ち、インストール。 -->

## Usage

### コマンドでファイルを破壊的に変更する方法

Command `rurema_fresh versions` destructively modifies the file.

コマンドを使って、ファイルを書き換えます。
念のためGitでコミットを打つなど戻せる状態でコマンドを実行してください。

`gem`コマンドではなく、`bundler`の`bundle`コマンドでGemfileで指定しインストールしている場合は、
`bundler`を通してコマンドを打てるように、
`bundle exec rurema_fresh versions`コマンドを打って下さい。

また、`versions`と複数形になっていることに注意してください。
複数の古いバージョン分岐を削除し、サポート対象範囲の複数のバージョンのものが残る可能性があるため、複数形にしています。

```sh
$ cat sample.rd
#@samplecode
#@since 2.4.0
puts "Hello, World!"
#@else
puts "Goodbye, World!"
#@end
#@end
#@until 2.3.0
#@samplecode
puts "old"
#@end
#@end

$ rurema_fresh versions sample.rb --ruby=2.4.0
sample.rd
上記のファイルについて、Ruby2.4.0より古い条件分岐がありました
9行、削除しました。

$ cat sample.rd
#@samplecode
puts "Hello, World!"
#@end
```

### コード上で、文字列から古い条件分岐を削除した文字列を生成して返す方法

コード上で文字列の条件分岐を削除するときは、以下のように使います。
```ruby
require 'rurema_fresh'

src = <<-'TEXT'
#@samplecode
#@since 1.9.0
# 0番目の文字を返す
p "abc"[0] #=> "a"
#@else
# 0番目の文字コードを返す
p "abc"[0] #=> 97
#@end
#@end
  TEXT

puts RuremaFresh.remove_old_versions(src, '2.4.0')
# alias RuremaFresh.versions
```
↓
```rb
#@samplecode
# 0番目の文字を返す
p "abc"[0] #=> "a"
#@end
```
引数の文字列を破壊的に変更することはなく、新しい文字列を生成して返します。

### versionsサブコマンドによるif文の対応

#### 対応済み
- `#@if( version >= "2.0.0")`は、`#@since 2.0.0`に置き換えた上で、古ければ削除します。
- `#@if( version < "2.0.0")`は、`#@until 2.0.0`に置き換えた上で、古ければ削除します。
- `#@if( version > "1.8.7")`は、`#@since 1.9.0`とバージョンを上げ置き換えた上で、古ければ削除します。
- `#@if( version <= "2.7.0")`は、`#@until 3.0.0`とバージョンを上げ置き換えた上で、古ければ削除します。
- `#@if( version == 1.0.0)`は、条件分岐が古ければ削除し、そうでなければif文のままです。
- `#@if( version != 1.0.0)`は、条件分岐が古ければ削除し、そうでなければif文のままです。
- `#@if ( "1.0.0" < version  and version <= "1.5.0" )`で、1つ目の条件分岐が古ければ、2つ目の式だけを`#@until`に置き換え、さらに古ければ削除します。1つめの条件分岐がサポート対象範囲の場合、if文のままです。

なお `#@if(`のように、`#@if`と`(`の間にスペースがないif文は、間にスペースを入れます。

#### 未対応

- `#@if ( "1.0.0" < version)`のように、具体的なバージョンが左のもの。
- `#@if ( version > "1.0.0" and version <= "3.0.0")`のような、両式のversionが中央に来てないもの。

これらの式が来たときは、スルーします。

## Development

<!-- After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org). -->

### 全体のテスト

当rurema_freshのディレクトリに移動した上で、
`rake test`ないし`rake`で、全体のテストを実行します。

もしくは、`ruby ./test/rurema_fresh_test`で実行できます。

### 個別のテスト

Ruby標準の`minitest`を用いテストを書いており、個別のテストメソッドを実行するには、
当rurema_freshのディレクトリに移動した上で、
`ruby ./test/rurema_fresh_test --name=test_remove_old_since1`
とテストしたいメソッド名を`name`オプションで指定することで実行できます。


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/universato/rurema_fresh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/universato/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).

改善に繋がるかもしれないと思えば、自由にPull RequestやIssueを送ってください。

## License

The gem is available as open source under the terms of the MIT.

ライセンスと良識の範囲で、自由に使ってください。

## Code of Conduct

Everyone interacting in the RuremaFresh project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/universato/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).
