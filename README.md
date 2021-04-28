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

$ rurema_fresh sample.rb --ruby==2.4.0

$ cat sample.rd
#@samplecode
puts "Hello, World!"
#@end
```

`#@if`ブロックには対応してないので、
`#@if`がある場合はファイルの編集をせずに終了します。

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

p RuremaFresh.remove_old_version(src, '2.4.0')
```
↓
```rb
#@samplecode
# 0番目の文字を返す
p "abc"[0] #=> "a"
#@end
```
引数の文字列を破壊的に変更することはなく、新しい文字列を返します。

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rurema_fresh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).

改善に繋がるかもしれないと思えば、自由にPull RequestやIssueを送ってください。

## License

The gem is available as open source under the terms of the CC0.

作成者は責任をとらないし、自由に使ってください。

## Code of Conduct

Everyone interacting in the RuremaFresh project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).
