# Use Ruby 3.3 (latest stable)
FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy gemspec and Gemfile
COPY brawo_cms.gemspec Gemfile* ./
COPY lib/brawo_cms/version.rb ./lib/brawo_cms/

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["bash"]

