FROM soutech/ruby:2.6-alpine-node

ENV APP_ROOT /champaign

RUN mkdir $APP_ROOT
ADD . $APP_ROOT
WORKDIR $APP_ROOT

RUN bundle install --jobs 4 --deployment --without development:test:doc

EXPOSE 3000
CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16
