# --- RAILS APPLICATION SETUP

FROM ruby:2.2.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy libpq-dev vim postgresql-9.4 imagemagick

# Create the application directory
RUN mkdir /myapp

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Install gems
RUN bundle install

EXPOSE 3000
ADD . /myapp
WORKDIR /myapp

# Remove existing server.pid file that'll prevent the service from spinning up
RUN rm -f /myapp/tmp/pids/server.pid
