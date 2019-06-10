require 'bot_twitter_ebooks'
require 'humanize'

# Information about a particular Twitter user we know
class UserInfo
  attr_reader :username

  # @return [Integer] how many times we can pester this user unprompted
  attr_accessor :pesters_left

  # @param username [String]
  def initialize(username)
    @username = username
    @pesters_left = 1
  end
end

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  attr_accessor :original, :model, :model_path

  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV['APP_CONSUMER_KEY'] # Your app consumer key
    self.consumer_secret = ENV['APP_CONSUMER_SECRET'] # Your app consumer secret

    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6

    @userinfo = {}
  end

  def top100; @top100 ||= model.keywords.take(100); end
  def top20;  @top20  ||= model.keywords.take(20); end

  # Find information we've collected about a user
  # @param username [String]
  # @return [Ebooks::UserInfo]
  def userinfo(username)
    @userinfo[username] ||= UserInfo.new(username)
  end

  # Check if we're allowed to send unprompted tweets to a user
  # @param username [String]
  # @return [Boolean]
  def can_pester?(username)
    userinfo(username).pesters_left > 0
  end

  # Only follow our original user or people who are following our original user
  # @param user [Twitter::User]
  def can_follow?(username)
    @original.nil? || username.casecmp(@original) == 0 || twitter.friendship?(username, @original)
  end

  def on_startup
    load_model!
    log top100

    scheduler.cron '0 * * * *' do
      # Tweet something every random amount of hours
      # See https://github.com/jmettraux/rufus-scheduler
      if rand(13) == 0
        delay do
          tweet(model.make_statement)
        end
      else
        log "I do not want to tweet"
      end
    end
  end

  def on_message(dm)
    # Follow & reply if user is following original account, unfollow & don't reply if not
    if can_follow?(dm.sender.screen_name)
      delay do
        follow(dm.sender.screen_name)
      end
    else
      log "Unfollowing @#{dm.sender.screen_name}"
      delay do
        twitter.unfollow(dm.sender.screen_name)
      end
      return
    end

    # Reply to a DM
    # Make sure to set your API permissions to "Read, Write and Access direct messages" or this won't work!
    if rand < 0.89
      delay do
        reply(dm, model.make_response(dm.text))
      end
    else
      log "I do not want to answer dms"
    end
  end

  def on_follow(user)
    # Follow a user back if is following original account
    if can_follow?(user.screen_name)
      delay do
        follow(user.screen_name)
      end
    else
      log "Not following @#{user.screen_name}"
    end
  end

  def on_mention(tweet)
    # Follow & reply if user is following original account, unfollow & don't reply if not
    if can_follow?(tweet.user.screen_name)
      delay do
        follow(tweet.user.screen_name)
      end
    else
      log "Unfollowing @#{tweet.user.screen_name}"
      delay do
        twitter.unfollow(tweet.user.screen_name)
      end
      return
    end

    # Become more inclined to pester a user when they talk to us
    userinfo(tweet.user.screen_name).pesters_left += 1

    # Reply to a mention
    if rand < 0.89
      delay do
        reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
      end
    else
      log "I do not want to answer tweets"
    end
  end

  def on_timeline(tweet)
    return if tweet.retweeted_status?
    return unless can_pester?(tweet.user.screen_name)

    # Unfollow & don't reply if user isn't following original account
    unless can_follow?(tweet.user.screen_name)
      log "Unfollowing @#{tweet.user.screen_name}"
      delay do
        twitter.unfollow(tweet.user.screen_name)
      end
      return
    end

    # Reply, fav & rt to a tweet in the bot's timeline if is interesting
    tokens = Ebooks::NLP.tokenize(tweet.text)

    interesting = tokens.find { |t| top100.include?(t.downcase) }
    very_interesting = tokens.find_all { |t| top20.include?(t.downcase) }.length > 2

    delay do
      if very_interesting && rand < 0.5
        delay do
          favorite(tweet)
        end

        delay do
          retweet(tweet) if rand < 0.1
        end

        if rand < 0.01
          userinfo(tweet.user.screen_name).pesters_left -= 1
          delay do
            reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
          end
        end
      elsif interesting && rand < 0.05
        delay do
          favorite(tweet)
        end

        if rand < 0.001
          userinfo(tweet.user.screen_name).pesters_left -= 1
          delay do
            reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
          end
        end

      end
    end
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet if is following original account
    if can_follow?(user.screen_name)
      delay do
        follow(user.screen_name)
      end
    else
      log "Not following @#{user.screen_name}"
    end
  end

  def on_retweet(tweet)
    # Follow user who just retweeted bot's tweet if is following original account
    if can_follow?(tweet.user.screen_name)
      delay do
        follow(tweet.user.screen_name)
      end
    else
      log "Not following @#{tweet.user.screen_name}"
    end
  end

  private
  def load_model!
    return if @model

    @model_path ||= "model/#{original}.model"

    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

# Make a MyBot and attach it to an account
number_of_bots = ENV['BOTS_NUMBER'].to_i

for bot_number in 1..number_of_bots
  num = bot_number.humanize.upcase
  MyBot.new(ENV["#{num}_NAME"]) do |bot|
    bot.access_token = ENV["#{num}_ACCESS_TOKEN_KEY"] # Token connecting the app to this account
    bot.access_token_secret = ENV["#{num}_ACCESS_TOKEN_SECRET"] # Secret connecting the app to this account
    bot.original = ENV["#{num}_ORIGINAL"]
  end
end
