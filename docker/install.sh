#!/bin/bash

# Update the package list and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Ruby and basic dependencies
sudo apt install -y ruby-full tzdata build-essential

# Install Bundler with a specific version
gem install bundler -v 2.4.13

# Set Bundler configuration
bundle config set --local deployment 'true'
bundle config set --local without 'development test'

# Install additional dependencies for build and runtime
sudo apt install -y \
  libpq-dev \
  libmariadb-dev \
  libarchive-dev \
  libgl1-mesa-dev \
  libglfw3-dev \
  nodejs \
  npm \
  redis-server \
  file \
  postgresql

# Install Foreman for runtime process management
gem install foreman

# Install Node.js and Yarn
sudo npm install --global corepack
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
