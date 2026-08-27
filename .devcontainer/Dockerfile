FROM ruby:3.3.0

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  libpq-dev \
  libvips42 \
  nodejs \
  npm \
  sudo \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

WORKDIR /workspace
