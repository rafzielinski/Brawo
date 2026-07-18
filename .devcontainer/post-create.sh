#!/usr/bin/env bash
set -euo pipefail

cd /workspace

echo "Installing gems..."
bundle config set --local path vendor/bundle
bundle install

echo "Syncing engine migrations into dummy app..."
mkdir -p test/dummy/db/migrate
cp -f db/migrate/*.rb test/dummy/db/migrate/ 2>/dev/null || true

echo "Setting up databases..."
cd test/dummy
bundle exec rails db:prepare
RAILS_ENV=test bundle exec rails db:prepare

echo ""
echo "Dev container ready."
echo "  Start server: cd test/dummy && bundle exec rails server -b 0.0.0.0"
echo "  Run tests:    bundle exec rspec"
echo "  Admin UI:     http://localhost:3000/admin"
