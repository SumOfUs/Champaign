FROM ruby:2.3.3

# Install system dependencies
RUN apt-get update -qq; apt-get install -y nodejs npm imagemagick netcat && \
    update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

RUN mkdir /myapp
WORKDIR /myapp

ADD Gemfile* /myapp/
ADD package.json /myapp/

RUN bundle install --jobs 4 && npm install && npm install -g phantomjs-prebuilt

EXPOSE 3000
ADD . /myapp

CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16
