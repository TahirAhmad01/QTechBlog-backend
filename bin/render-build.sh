#!/usr/bin/env bash
# exit on error
set -o errexit
cp .env.sample .env

#rm -d config/credentials.yml.enc
# rails credentials:edit

bundle install
rails db:create
rails db:migrate
