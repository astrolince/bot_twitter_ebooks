# ebooks_example

This is the [bot_twitter_ebooks](https://github.com/astrolince/bot_twitter_ebooks) app which I use to run most of my own bots. It tweets one tweet every random hours determined by a simple will factor, responds to interactions, and has some small unprompted interaction probability based on keyword matching.

## Usage

Set at least these env vars (in Heroku `app > Settings > Config Variables`, in Now.sh check `now.json` secrets):

```
ONE_ACCESS_TOKEN_KEY (Twitter access token key)
ONE_ACCESS_TOKEN_SECRET (Twitter access token secret)
ONE_NAME (Bot username)
ONE_ORIGINAL (Twitter account that the bot is copycatting)
APP_CONSUMER_KEY (Twitter app consumer key)
APP_CONSUMER_SECRET (Twitter app consumer secret)
BOTS_NUMBER (Number of bots)
```

Clone repo and create models:

```bash
git clone https://github.com/astrolince/ebooks_example.git
cd ebooks_example
bundle install
export username=ONE_ORIGINAL
ebooks archive $username corpus/$username.json
ebooks consume corpus/$username.json
```

And then:

`ebooks start`

Or just push it to Heroku or Now.sh.

See the [bot_twitter_ebooks](https://github.com/astrolince/bot_twitter_ebooks) README for more information.
