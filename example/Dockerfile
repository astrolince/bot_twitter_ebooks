FROM ruby:alpine
LABEL name "ebooks_example"

RUN apk update && apk upgrade && apk add bash make g++ tzdata

RUN mkdir /usr/src/app
COPY . /usr/src/app
WORKDIR /usr/src/app

RUN bundle install

EXPOSE 3000

CMD ./start.sh
