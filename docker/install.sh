#!/bin/bash

# Update the package list and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install essential tools and libraries
sudo apt install -y build-essential curl apt-transport-https gnupg ca-certificates

# Remove old/conflicting Node.js version
sudo apt remove -y libnode-dev nodejs-doc

# Add the Node.js 20.x repository and install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js and npm versions
node -v
npm -v

# Install Corepack and enable Yarn
sudo npm install --global corepack
corepack enable yarn

# Install Ruby and essential development libraries
sudo apt install -y ruby-full libpq-dev libmariadb-dev libarchive-dev libgl1-mesa-dev libglfw3-dev redis-server

# Ensure Bundler is installed and set the path correctly for user gems
gem install --user-install bundler -v 2.4.13
echo 'export PATH=$HOME/.local/share/gem/ruby/$(ruby -e "puts RUBY_VERSION").0/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Install Foreman for runtime process management
gem install --user-install foreman

# Verify Ruby, Bundler, and Foreman installations
ruby -v
bundle -v
foreman -v

# Install project dependencies using Yarn (ensure package.json and yarn.lock are present in the current directory)
yarn install

# Install Ruby gems (ensure Gemfile and Gemfile.lock are present in the current directory)
bundle install

# Precompile assets for the application
DATABASE_URL="nulldb://user:pass@localhost/db" \
SECRET_KEY_BASE="placeholder" \
RACK_ENV="production" \
bundle exec rake assets:precompile

echo "All dependencies installed. You can now run the Manyfold application."
