FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev vim postgresql-9.4

RUN mkdir /listeners

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /myapp
WORKDIR /myapp
