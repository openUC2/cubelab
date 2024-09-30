#!/bin/bash

# Update the package list and install basic dependencies
sudo apk update && sudo apk upgrade

# Install Ruby, Bundler, and basic packages
sudo apk add --no-cache ruby=3.3.5-alpine tzdata

# Install Bundler with a specific version
gem install bundler -v 2.4.13

# Set Bundler configuration
bundle config set --local deployment 'true'
bundle config set --local without 'development test'

# Install additional dependencies for build and runtime
sudo apk add --no-cache \
  alpine-sdk \
  nodejs=~20.15 \
  npm \
  postgresql-dev \
  mariadb-dev \
  libarchive \
  mesa-gl \
  glfw \
  file \
  s6-overlay \
  redis

# Install Foreman for runtime process management
gem install foreman

# Install Node.js and Yarn
npm install --global corepack
corepack enable yarn

# Install project dependencies (Ensure package.json and yarn.lock are in the current directory)
yarn install

# Install Ruby gems (Ensure Gemfile and Gemfile.lock are in the current directory)
bundle install

# Precompile assets for the application
DATABASE_URL="nulldb://user:pass@localhost/db" \
SECRET_KEY_BASE="placeholder" \
RACK_ENV="production" \
bundle exec rake assets:precompile

echo "All dependencies installed. You can now run the Manyfold application."
