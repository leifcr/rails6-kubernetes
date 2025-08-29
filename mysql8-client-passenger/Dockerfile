FROM ruby:3.1
LABEL org.opencontainers.image.authors='leifcr@gmail.com'
LABEL description='Image for running rails 6 apps on kubernetes with mysql-8 client libs, with common gems preinstalled. Based on ruby:2.6 image'

ENV APP_HOME /app
ENV LANG C.UTF-8

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3A79BD29
# RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 3A79BD29
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
       rsync \
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

############################################
# Compile Passenger fork: ensure submodules + compile agent
############################################
# (Independent of app source; only changes if Gemfile or Passenger fork commit changes)

# Step 1: Ensure fork + submodules present
RUN set -Eeuo pipefail; \
  echo "[1/3] Preparing passenger source"; \
  PASSENGER_DIR="$(bundle show passenger)"; \
  echo "Passenger dir: $PASSENGER_DIR"; \
  if [ -d "${PASSENGER_DIR}/.git" ]; then \
    echo "Updating submodules in existing passenger checkout"; \
    git -C "${PASSENGER_DIR}" submodule sync --recursive; \
    git -C "${PASSENGER_DIR}" submodule update --init --recursive; \
  else \
    echo "No .git in installed passenger gem; cloning fork (with submodules)"; \
    command -v rsync >/dev/null || { echo "ERROR: rsync not installed"; exit 1; }; \
    TMP_CLONE="$(mktemp -d)"; \
    git clone --branch stable-6.0 --recursive https://github.com/leifcr/passenger.git "$TMP_CLONE"; \
    rsync -a --delete "$TMP_CLONE"/ "${PASSENGER_DIR}/"; \
    rm -rf "$TMP_CLONE"; \
  fi; \
  echo "Listing critical vendor path (cxxcodebuilder expected)"; \
  ls -1 "${PASSENGER_DIR}/build/support/vendor" || true

# Step 2: Validate required submodule file
RUN set -Eeuo pipefail; \
  echo "[2/3] Validating submodules"; \
  PASSENGER_DIR="$(bundle show passenger)"; \
  TARGET="${PASSENGER_DIR}/build/support/vendor/cxxcodebuilder/lib/cxxcodebuilder.rb"; \
  if [ ! -f "$TARGET" ]; then \
    echo "ERROR: cxxcodebuilder missing: $TARGET"; \
    find "${PASSENGER_DIR}/build/support/vendor" -maxdepth 4 -type f | head -n 100; \
    exit 1; \
  fi; \
  echo "Submodule OK"

# Step 3: Compile agent + native support with debug logging
RUN set -Eeuo pipefail; \
  echo "[3/3] Compiling passenger agent"; \
  PASSENGER_DIR="$(bundle show passenger)"; \
  rm -rf "${PASSENGER_DIR}/.git" || true; \
  export CFLAGS='-O3 -fno-omit-frame-pointer -pipe' \
         CXXFLAGS='-O3 -fno-omit-frame-pointer -pipe' \
         MAKEFLAGS="-j$(nproc)" \
         PASSENGER_DEBUG=1; \
  bundle exec passenger-config --version; \
  echo "Running compile-agent (verbose)"; \
  if ! bundle exec passenger-config compile-agent --optimize --verbose; then \
    echo "compile-agent failed. Recent buildout logs:"; \
    find "${PASSENGER_DIR}/buildout" -maxdepth 2 -type f -name '*.log' -print -exec tail -n 50 {} \; || true; \
    exit 1; \
  fi; \
  echo "Building native support"; \
  if ! bundle exec passenger-config build-native-support --verbose; then \
    echo "build-native-support failed"; \
    exit 1; \
  fi; \
  echo "Validating install"; \
  bundle exec passenger-config validate-install --auto || { echo 'validate-install failed'; exit 1; }

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
