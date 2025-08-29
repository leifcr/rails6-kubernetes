FROM ruby:3.1
LABEL org.opencontainers.image.authors='leifcr@gmail.com'
LABEL description='Image for running rails 6 apps on kubernetes with mysql-8 client libs, with common gems preinstalled. Based on ruby:2.6 image'

ENV APP_HOME /app
ENV LANG C.UTF-8

# Install dependencies
RUN set -eux; \
    . /etc/os-release; CODENAME="${VERSION_CODENAME}"; echo "Detected Debian codename: $CODENAME"; \
    apt-get update -q; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg dirmngr; \
    mkdir -p /usr/share/keyrings; \
    # Yarn repo
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list; \
    # NodeSource (adjust node_20.x if needed)
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - ; \
    # MySQL APT repo (only if codename supported)
    curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --dearmor -o /usr/share/keyrings/mysql.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] https://repo.mysql.com/apt/debian ${CODENAME} mysql-8.0" > /etc/apt/sources.list.d/mysqlclient.list; \
    apt-get update -q; \
    apt-get install -y --no-install-recommends \
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
       libssl-dev \
       zlib1g-dev \
       libcurl4-openssl-dev \
       libpcre3-dev \
    || { echo "APT install failed (codename=${CODENAME}). Showing sources.list & errors."; grep -R ^deb /etc/apt/sources.list*; exit 1; }; \
     # Create app user setup
     set -x; \
     mkdir -p "$APP_HOME"; \
     groupadd -g 1001 rails; \
     useradd -s /bin/bash -m -d /home/rails --uid 1001 -g rails rails; \
     chown rails:rails /app; \
     # Remove build-time only GPG tooling (optional)
     apt-get purge -y --auto-remove gnupg dirmngr; \
     rm -rf /var/lib/apt/lists/*

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
