FROM ruby:2.2.2
# Install system dependencies
RUN apt-get update -qq && apt-get install -y nodejs imagemagick netcat

RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile* /myapp/
RUN bundle install

EXPOSE 3000
ADD . /myapp

CMD bundle exec unicorn -l 0.0.0.0:3000
