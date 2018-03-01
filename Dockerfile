FROM ruby:2.4.1

ENV APP_ROOT /champaign

# Install ImageMagick and apt-transport-https (to install nodesource)
RUN apt-get update -qq && apt-get install -y apt-transport-https imagemagick

# Install Node.js 7.x
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
 && echo 'deb https://deb.nodesource.com/node_7.x jessie main' > /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -qq && apt-get install -y nodejs

# Create app folder and add current dir contents
RUN mkdir $APP_ROOT
ADD . $APP_ROOT
WORKDIR $APP_ROOT

RUN bundle install --jobs 4 --deployment --without development:test:doc

EXPOSE 3000
CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16
