ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=

FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libpq5 curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

EXPOSE 5000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "5000"]
