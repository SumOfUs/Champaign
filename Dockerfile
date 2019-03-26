FROM ruby:2.4.5-stretch

ENV APP_ROOT /champaign

# Install ImageMagick and apt-transport-https (to install nodesource)
RUN apt-get update -qq && apt-get install -y apt-transport-https imagemagick

# Install Node.js 11.x
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - \
  && apt-get install -y nodejs

RUN apt-get update -qq && apt-get install -y nodejs

# Create app folder and add current dir contents
RUN mkdir $APP_ROOT
ADD . $APP_ROOT
WORKDIR $APP_ROOT

RUN gem install bundler
RUN bundle install --jobs 4 --deployment --without development:test:doc

EXPOSE 3000
CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16
