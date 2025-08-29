FROM ruby:3.1
LABEL org.opencontainers.image.authors='leifcr@gmail.com'
LABEL description='Image for running rails 6 apps on kubernetes with mysql-8 client libs, with common gems preinstalled. Based on ruby:2.6 image'

ENV APP_HOME /app
ENV LANG C.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3A79BD29
# RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 3A79BD29

# Install dependencies
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

############################################
# Compile Passenger fork: ensure submodules + compile agent
############################################
# (Independent of app source; only changes if Gemfile or Passenger fork commit changes)
RUN set -eu; \
  PASSENGER_DIR="$(bundle show passenger)"; \
  echo "Passenger dir: $PASSENGER_DIR"; \
  if [ -d "${PASSENGER_DIR}/.git" ]; then \
    echo "Updating submodules in existing passenger checkout"; \
    git -C "${PASSENGER_DIR}" submodule update --init --recursive; \
  else \
    echo "No .git in installed passenger gem; full recursive clone overlay"; \
    TMP_CLONE="$(mktemp -d)"; \
    git clone --branch stable-6.0 --recursive https://github.com/leifcr/passenger.git "$TMP_CLONE"; \
    rsync -a --delete "$TMP_CLONE"/ "${PASSENGER_DIR}/"; \
    rm -rf "$TMP_CLONE"; \
  fi; \
  if [ ! -f "${PASSENGER_DIR}/build/support/vendor/cxxcodebuilder/lib/cxxcodebuilder.rb" ]; then \
    echo "ERROR: cxxcodebuilder still missing after submodule init/clone"; \
    ls -R "${PASSENGER_DIR}/build/support/vendor" || true; \
    exit 1; \
  fi; \
  rm -rf "${PASSENGER_DIR}/.git"; \
  echo "Compiling Passenger agent (optimized)"; \
  export CFLAGS='-O3 -fno-omit-frame-pointer -pipe' \
         CXXFLAGS='-O3 -fno-omit-frame-pointer -pipe' \
         MAKEFLAGS="-j$(nproc)"; \
  bundle exec passenger-config compile-agent --optimize; \
  bundle exec passenger-config build-native-support; \
  bundle exec passenger-config validate-install --auto;
# RUN apt-get purge -y git rsync && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Build passenger standalone (nginx)
# Prebuild Passenger standalone (Nginx) runtime so it won't compile at boot
RUN set -e; \
  echo "Installing Passenger standalone runtime (Nginx engine)"; \
  bundle exec passenger-config install-standalone-runtime --auto; \
  # Sanity check: should list an 'Nginx engine' section
  bundle exec passenger-config about standalone-runtime | grep -i nginx || (echo "Nginx runtime missing" && exit 1)

ENV PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0 \
    PASSENGER_COMPILE_NATIVE_SUPPORT_BINARY=0

# Set entry point to bundle exec, as all cmd's with rails should be prepended
ENTRYPOINT ["docker-entrypoint.sh"]
