$debug = false

def log(*args)
  STDERR.print args.map(&:to_s).join(' ') + "\n"
  STDERR.flush
end

module Ebooks
  GEM_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  DATA_PATH = File.join(GEM_PATH, 'data')
  SKELETON_PATH = File.join(GEM_PATH, 'skeleton')
  TEST_PATH = File.join(GEM_PATH, 'test')
  TEST_CORPUS_PATH = File.join(TEST_PATH, 'corpus/elonmusk.tweets')
  INTERIM = :interim
end

require 'bot_twitter_ebooks/nlp'
require 'bot_twitter_ebooks/archive'
require 'bot_twitter_ebooks/sync'
require 'bot_twitter_ebooks/suffix'
require 'bot_twitter_ebooks/model'
require 'bot_twitter_ebooks/bot'
