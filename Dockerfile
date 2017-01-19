FROM ruby:2.4.0

# With --build-arg ci=false we'll skip the bundle install part
ARG ci
ENV CI ${ci:-false}
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

# Install all gems if CI=false. Install deployment gems if CI=true
RUN if [ $CI = false ]; then bundle install --jobs 4; fi
RUN if [ $CI = true ]; then bundle install --jobs 4 --deployment --without development:test:doc; fi

EXPOSE 3000
CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16
