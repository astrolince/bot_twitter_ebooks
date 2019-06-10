# bot_twitter_ebooks

[![Gem Version](https://badge.fury.io/rb/bot_twitter_ebooks.svg)](http://badge.fury.io/rb/bot_twitter_ebooks)
[![Build Status](https://travis-ci.org/astrolince/bot_twitter_ebooks.svg)](https://travis-ci.org/astrolince/bot_twitter_ebooks)
[![Dependency Status](https://gemnasium.com/astrolince/bot_twitter_ebooks.svg)](https://gemnasium.com/astrolince/bot_twitter_ebooks)

A framework for building interactive twitterbots which generate tweets based on pseudo-Markov texts models and respond to mentions/DMs/favs/rts. See the [example](example/README.md) for a fully-fledged bot definition.

## New in 3.0

- About 80% less memory and storage use for models
- Bots run in their own threads (no eventmachine), and startup is parallelized
- Bots start with `ebooks start`, and no longer die on unhandled exceptions
- `ebooks auth` command will create new access tokens, for running multiple bots
- `ebooks console` starts a ruby interpreter with bots loaded (see Ebooks::Bot.all)
- Replies are slightly rate-limited to prevent infinite bot convos
- Non-participating users in a mention chain will be dropped after a few tweets
- [API documentation](http://rdoc.info/github/astrolince/bot_twitter_ebooks) and tests

Note that 3.0 is not backwards compatible with 2.x, so upgrade carefully! In particular, **make sure to regenerate your models** since the storage format changed.

## Installation

Requires Ruby 2.4+.

```bash
gem install bot_twitter_ebooks
```

## Setting up a bot

Run `ebooks new <reponame>` to generate a new repository containing a sample bots.rb file, which looks like this:

``` ruby
# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = '' # Your app consumer key
    self.consumer_secret = '' # Your app consumer secret

    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup
    scheduler.every '24h' do
      # Tweet something every 24 hours
      # See https://github.com/jmettraux/rufus-scheduler
      # tweet("hi")
      # pictweet("hi", "cuteselfie.jpg")
    end
  end

  def on_message(dm)
    # Reply to a DM
    # Make sure to set your API permissions to "Read, Write and Access direct messages" or this won't work!
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    # follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    # reply(tweet, "oh hullo")
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet
    # follow(user.screen_name)
  end

  def on_retweet(tweet)
    # Follow user who just retweeted bot's tweet
    # follow(tweet.user.screen_name)
  end
end

# Make a MyBot and attach it to an account
MyBot.new("elonmusk_ebooks") do |bot|
  bot.access_token = "" # Token connecting the app to this account
  bot.access_token_secret = "" # Secret connecting the app to this account
end
```

`ebooks start` will run all defined bots in their own threads. The easiest way to run bots in a semi-permanent fashion is with [Heroku](https://www.heroku.com); just make an app, push the bot repository to it, enable a worker process in the web interface and it ought to chug along merrily forever.

The underlying streaming and REST clients from the [twitter gem](https://github.com/sferik/twitter) can be accessed at `bot.stream` and `bot.twitter` respectively.

## Archiving accounts

bot_twitter_ebooks comes with a syncing tool to download and then incrementally update a local json archive of a user's tweets (in this case, my good friend @elonmusk):

``` zsh
➜  ebooks archive elonmusk corpus/elonmusk.json
Currently 2584 tweets for elonmusk
Received 34 new tweets
```

The first time you'll run this, it'll ask for auth details to connect with. Due to API limitations, for users with high numbers of tweets it may not be possible to get their entire history in the initial download. However, so long as you run it frequently enough you can maintain a perfect copy indefinitely into the future.

If you have full access to the account you can request your full Twitter archive in web settings and convert the tweets.csv to .json with the command: `ebooks jsonify tweets.csv`

## Text models

In order to use the included text modeling, you'll first need to preprocess your archive into a more efficient form:

``` zsh
➜  ebooks consume corpus/elonmusk.json
Reading json corpus from corpus/elonmusk.json
Removing commented lines and sorting mentions
Segmenting text into sentences
Tokenizing 987 statements and 1597 mentions
Ranking keywords
Corpus consumed to model/elonmusk.model
```

Notably, this works with both json tweet archives and plaintext files (based on file extension), so you can make a model out of any kind of text.

Text files use newlines and full stops to seperate statements.

You can also consume multiple archives / plaintext files into a single model using `ebooks consume-all <model_name> <corpus_paths>`.

Once you have a model, the primary use is to produce statements and related responses to input, using a pseudo-Markov generator:

``` ruby
> model = Ebooks::Model.load("model/elonmusk.model")
> model.make_statement(140)
=> "Rainbows, unicorns and LA and seems to be working on the Falcon fireball investigation."
> model.make_response("Will you give free trips to Mars?", 130)
=> "Plan is to provide something special that only existing owners can give to friends and it is limited to 5 people."
```

The secondary function is the "interesting keywords" list. For example, I use this to determine whether a bot wants to fav/retweet/reply to something in its timeline:

``` ruby
top100 = model.keywords.take(100)
tokens = Ebooks::NLP.tokenize(tweet.text)

if tokens.find { |t| top100.include?(t) }
  favorite(tweet)
end
```

## Bot niceness

bot_twitter_ebooks will drop bystanders from mentions for you and avoid infinite bot conversations, but it won't prevent you from doing a lot of other spammy things. Make sure your bot is a good and polite citizen!

## License

bot_twitter_ebooks is [MIT licensed](https://github.com/astrolince/bot_twitter_ebooks/blob/master/LICENSE) and is a fork of [twitter_ebooks](https://github.com/mispy/twitter_ebooks).

Thanks to Jaiden Mispy ([@mispy](https://github.com/mispy)) and all the human beings/bots/star stuff affected by universe entropy that contribute to the project.
