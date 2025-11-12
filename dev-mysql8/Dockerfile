FROM ruby:3.1
LABEL org.opencontainers.image.authors='leifcr@gmail.com'
LABEL description='Image for running rails 6 apps on kubernetes, with common gems preinstalled. Based on ruby:2.6 image'

ENV APP_HOME='/app'
ENV LANG='C.UTF-8'

# Install dependencies
RUN set -eux; \
    . /etc/os-release; CODENAME="${VERSION_CODENAME}"; echo "Detected Debian codename: $CODENAME"; \
    apt-get update -q; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg dirmngr; \
    mkdir -p /usr/share/keyrings; \
    # Yarn repo
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list; \
    # NodeSource
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    # MySQL repo key (full key from ubuntu keyserver; avoids trimmed key issue)
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB7B3B788A8D3785C" | gpg --dearmor -o /usr/share/keyrings/mysql.gpg; \
    gpg --show-keys --keyid-format long /usr/share/keyrings/mysql.gpg | grep -q B7B3B788A8D3785C || { echo 'MySQL key missing expected ID'; exit 1; }; \
    echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] https://repo.mysql.com/apt/debian ${CODENAME} mysql-8.0" > /etc/apt/sources.list.d/mysqlclient.list; \
    # Chrome key
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg; \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list; \
    apt-get update -q; \
    apt-get install -y --no-install-recommends apt-transport-https; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get update -q && apt-get install -y \
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
    && apt-get install -y google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* && \
    set -x && \
    mkdir $APP_HOME && \
    groupadd -g 1001 rails && \
    useradd -s /bin/bash -m -d /home/rails --uid 1001 -g rails rails && \
    chown rails:rails /app

# Copy Imagemagick policy to allow converting PDF to thumbnails
COPY imagemagick_policy.xml /etc/ImageMagick-6/policy.xml

# Copy docker entry point
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

USER rails
WORKDIR $APP_HOME

COPY --chown=rails:rails Gemfile Gemfile.lock update_webdrivers.rb ./
RUN gem install bundler && bundle install --jobs 20 --retry 5 && bundle exec ruby update_webdrivers.rb && yarn install

ENTRYPOINT ["docker-entrypoint.sh"]
