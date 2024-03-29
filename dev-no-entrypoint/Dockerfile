FROM ruby:3.1
LABEL org.opencontainers.image.authors='leifcr@gmail.com'
LABEL description='Image for running rails 6 apps on kubernetes, with common gems preinstalled. Based on ruby:2.6 image'

ENV APP_HOME /app
ENV LANG C.UTF-8

# For stretch:
# RUN  apt-get install -y apt-transport-https ca-certificates gnupg wget --no-install-recommends && \
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update -q && apt-get upgrade -y \
    && apt-get install -y \
       build-essential \
       git \
       default-libmysqlclient-dev \
       libxml2-dev \
       libxslt1-dev \
       ghostscript \
       default-mysql-client \
       postgresql-client \
       wget \
       curl \
       nodejs \
       yarn \
       cargo \
    && apt-get install -y google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* && \
    set -x && \
    mkdir $APP_HOME && \
    groupadd -g 1001 rails && \
    useradd -s /bin/bash -m -d /home/rails --uid 1001 -g rails rails && \
    chown rails:rails /app

# Copy Imagemagick policy to allow converting PDF to thumbnails
COPY imagemagick_policy.xml /etc/ImageMagick-6/policy.xml

# Continue as rails user
USER rails

# Set workdir to /app, so COPY, ADD, RUN and ENTRYPOINT is run within folder
WORKDIR $APP_HOME

# Add Gemfile
COPY --chown=rails:rails Gemfile Gemfile.lock update_webdrivers.rb ./
# Install gems
RUN gem install bundler && bundle install --jobs 20 --retry 5 && bundle exec ruby update_webdrivers.rb && yarn install
