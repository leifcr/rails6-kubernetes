FROM ruby:3.1
LABEL org.opencontainers.image.authors='leifcr@gmail.com'
LABEL description='Image for running rails 6 apps on kubernetes with mysql-8 client libs, with common gems preinstalled. Based on ruby:2.6 image'

ENV APP_HOME /app
ENV LANG C.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3A79BD29
# RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 3A79BD29

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key B7B3B788A8D3785C \
    && echo "deb https://repo.mysql.com/apt/debian/ bookworm mysql-8.0" | tee /etc/apt/sources.list.d/mysqlclient.list \
    && apt-get update -q && apt-get upgrade -y \
    && apt-get install -y \
       build-essential \
       git \
       libxml2-dev \
       libxslt1-dev \
       ghostscript \
       libmysqlclient-dev \
       libmysqlclient21 \
       mysql-client \
       postgresql-client \
       wget \
       curl \
       nodejs \
       yarn \
       cargo \
    && set -x && \
    mkdir $APP_HOME && \
    groupadd -g 1001 rails && \
    useradd -s /bin/bash -m -d /home/rails --uid 1001 -g rails rails && \
    chown rails:rails /app

# Copy Imagemagick policy to allow converting PDF to thumbnails
COPY imagemagick_policy.xml /etc/ImageMagick-6/policy.xml

# Copy docker entry point
COPY docker-entrypoint.sh /usr/local/bin/

# Make entrypoint executable when building on Windows
# And backwards compatible entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Continue as rails user
USER rails

# Set workdir to /app, so COPY, ADD, RUN and ENTRYPOINT is run within folder
WORKDIR $APP_HOME

# Add Gemfile
COPY --chown=rails:rails Gemfile Gemfile.lock ./
# Install gems
RUN gem install bundler && BUNDLE_WITHOUT="development:test" bundle install --jobs 20 --retry 5

# Set entry point to bundle exec, as all cmd's with rails should be prepended
ENTRYPOINT ["docker-entrypoint.sh"]
