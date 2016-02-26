FROM ruby:2.3.0
# Install system dependencies
RUN apt-get update -qq; apt-get install -y nodejs npm imagemagick netcat && \
    update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

RUN mkdir /myapp
WORKDIR /myapp

ADD Gemfile* /myapp/
ADD package.json /myapp/

RUN bundle install --jobs 4 && npm install

EXPOSE 3000
ADD . /myapp
RUN RAILS_ENV=production bundle exec rake assets:precompile

CMD bundle exec puma -C config/puma.rb
