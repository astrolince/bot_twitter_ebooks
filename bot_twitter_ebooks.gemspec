# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bot_twitter_ebooks/version', __FILE__)

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.4'

  spec.name          = "bot_twitter_ebooks"
  spec.version       = Ebooks::VERSION
  spec.licenses      = ["MIT"]
  spec.summary       = "Better twitterbots for all your friends~"
  spec.description   = "A framework for building interactive twitterbots which generate tweets based on pseudo-Markov texts models and respond to mentions/DMs/favs/rts."
  spec.homepage      = "https://github.com/astrolince/bot_twitter_ebooks"

  spec.authors       = ["astrolince"]
  spec.email         = ["astro@astrolince.com"]

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rspec-mocks', '~> 3.7'
  spec.add_development_dependency 'memory_profiler', '~> 0.9'
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency 'pry-byebug', '~> 3.5'
  spec.add_development_dependency 'yard', '~> 0.9'

  spec.add_runtime_dependency 'twitter', '~> 6.2'
  spec.add_runtime_dependency 'rufus-scheduler', '~> 3.4'
  spec.add_runtime_dependency 'gingerice', '~> 1.2'
  spec.add_runtime_dependency 'htmlentities', '~> 4.3'
  spec.add_runtime_dependency 'engtagger', '~> 0.2'
  spec.add_runtime_dependency 'fast-stemmer', '~> 1.0'
  spec.add_runtime_dependency 'highscore', '~> 1.2'
  spec.add_runtime_dependency 'pry', '~> 0.11'
  spec.add_runtime_dependency 'oauth', '~> 0.5'
  spec.add_runtime_dependency 'mini_magick', '~> 4.8'
end
