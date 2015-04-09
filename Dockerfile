FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy libpq-dev vim
RUN npm install -g phantomjs

RUN mkdir /myapp

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /myapp
WORKDIR /myapp
