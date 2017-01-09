FROM ruby:2.3.3

# Pre install dependencies
RUN apt-get update -qq
RUN apt-get install -y apt-transport-https imagemagick netcat

# Add Node and Yarn sources
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo 'deb https://deb.nodesource.com/node_7.x jessie main' > /etc/apt/sources.list.d/nodesource.list
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install system dependencies
RUN apt-get update -qq
RUN apt-get install -y nodejs yarn

RUN mkdir /myapp
WORKDIR /myapp

ADD Gemfile* /myapp/
ADD package.json /myapp/
ADD yarn.lock /myapp/

RUN yarn install --no-progress --no-emoji
RUN bundle install --jobs 4

EXPOSE 3000

ADD . /myapp

CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16
