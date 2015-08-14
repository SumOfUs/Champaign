# --- RAILS APPLICATION SETUP

FROM ruby:2.2.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy libpq-dev vim imagemagick netcat

# Create the application directory
RUN mkdir /myapp

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY package.json package.json
RUN npm install
RUN bundle install

EXPOSE 3000
ADD . /myapp
WORKDIR /myapp

CMD bundle exec rails s -b 0.0.0.0