FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy libpq-dev vim postgresql-9.4 imagemagick

RUN mkdir /myapp

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

EXPOSE 3000
ADD . /myapp
WORKDIR /myapp

RUN rm -f /myapp/tmp/pids/server.pid
