# RuremaFresh

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rurema_fresh`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rurema_fresh'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rurema_fresh

## Usage

Command `rurema_fresh` destructively modifies the file.
so

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rurema_fresh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuremaFresh project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rurema_fresh/blob/master/CODE_OF_CONDUCT.md).