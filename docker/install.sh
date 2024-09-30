#!/bin/bash

# Update the package list and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Ruby and basic dependencies
sudo apt install -y ruby-full tzdata build-essential

# Install Bundler with a specific version
gem install --user-install bundler -v 2.4.13
export PATH=$HOME/.gem/ruby/$(ruby -e 'puts RUBY_VERSION').0/bin:$PATH

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

# Ensure Node.js is up-to-date (remove the old version and install a new one)
sudo apt remove -y nodejs
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Corepack and enable Yarn
sudo npm install --global corepack
corepack enable yarn

# Install project dependencies (Ensure package.json and yarn.lock are in the current directory)
yarn install

# Install Ruby gems (Ensure Gemfile and Gemfile.lock are in the current directory)
bundle install

# Install Foreman for runtime process management
gem install --user-install foreman

# Precompile assets for the application
DATABASE_URL="nulldb://user:pass@localhost/db" \
SECRET_KEY_BASE="placeholder" \
RACK_ENV="production" \
bundle exec rake assets:precompile

echo "All dependencies installed. You can now run the Manyfold application."
