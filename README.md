# RuremaFresh

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rurema_fresh`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

主なインストール方法を、2つ紹介します。

- `bundler`を用いてインストールする。
  1. `Gemfile`に`gem 'rurema_fresh'`と書きます。
  2. コマンド`bundle install`で、Gemfile(& Gemfile.lock)に従って、インストール。
- コマンド`gem install rurema_fresh`を打ち、インストール。

## Usage

### コマンドでファイルを破壊的に変更する方法

Command `rurema_fresh` destructively modifies the file.

コマンドを使って、ファイルを書き換えます。
念のためGitでコミットを打つなど戻せる状態でコマンドを実行してください。

```
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

$ rurema_fresh version sample.rb --ruby=2.4.0
sample.rd
上記のファイルについて、Ruby2.4.0より古い条件分岐がありました
9行、削除しました。

$ cat sample.rd
#@samplecode
puts "Hello, World!"
#@end
```

`#@if`ブロックには一部のみ対応してます。後述

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

puts RuremaFresh.remove_old_version(src, '2.4.0')
# alias RuremaFresh.version
```
↓
```rb
#@samplecode
# 0番目の文字を返す
p "abc"[0] #=> "a"
#@end
```
引数の文字列を破壊的に変更することはなく、新しい文字列を生成して返します。

### if文の対応状況

言い訳ですが、作り始めたときに`#@since`と`#@until`しか念頭になかったので、部分対応です。

対応済み
- `#@if( version >= "2.0.0")`は、`#@since 2.0.0`に置き換えた上で、古ければ削除します。
- `#@if( version < "2.0.0")`は、`#@until 2.0.0`に置き換えた上で、古ければ削除します。

一応は対応済み
- `#@if( version > "2.0.0")`は、`#@since 2.0.1`に置き換えた上で、古ければ削除します。
- `#@if( version <= "2.0.0")`は、`#@until 1.9.9`に置き換えた上で、古ければ削除します。
- `#@if( version == 1.0.0)`は、条件分岐が古ければ削除し、そうでなければif文のままです。
- `#@if( version != 1.0.0)`は、条件分岐が古ければ削除し、そうでなければif文のままです
- `#@if ( "1.0.0" < version  and version <= "1.5.0" )`で、1つ目の条件分岐が古ければ削除し、2つ目の式だけを`#@until`に置き換えた上で、古ければ削除します。1つめの条件分岐がサポート対象範囲の場合は、そうでなければif文のままです

未対応

- `#@if ( "1.0.0" < version)`のように、具体的なバージョンが左のもの。
- `#@if ( version > "1.0.0" and version <= "3.0.0")`のような、両式のversionが中央に来てないもの。

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rurema_fresh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).

改善に繋がるかもしれないと思えば、自由にPull RequestやIssueを送ってください。

## License

The gem is available as open source under the terms of the MIT.

自由に使ってください。

## Code of Conduct

Everyone interacting in the RuremaFresh project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).
