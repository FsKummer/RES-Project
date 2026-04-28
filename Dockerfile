FROM node:20-bullseye AS node

FROM ruby:3.1.2

ENV BUNDLE_JOBS=4 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_RETRY=3 \
    LANG=C.UTF-8

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git \
      libglib2.0-0 \
      libglib2.0-dev \
      libpoppler-glib8 \
      libsqlite3-dev \
      libvips-dev \
      pkg-config \
      sqlite3 && \
    gem install bundler:2.3.25 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    npm install --global yarn@1.22.22

WORKDIR /rails

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .

RUN mkdir -p app/assets/builds log storage tmp/pids && \
    chmod -R a+rwX /usr/local/bundle node_modules app/assets/builds log storage tmp

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
