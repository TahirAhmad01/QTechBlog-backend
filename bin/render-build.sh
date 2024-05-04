#!/usr/bin/env bash
# exit on error
set -o errexit
cp .env.sample .env

bundle install
rails db:create
rails db:migrate