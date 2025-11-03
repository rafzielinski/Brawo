#!/bin/bash

set -e  # Exit on error

echo "🚀 Setting up BrawoCMS Development Environment"
echo "=============================================="
echo ""

# Build Docker containers
echo "📦 Building Docker containers..."
if ! docker-compose build; then
    echo "❌ Failed to build containers"
    exit 1
fi

# Start services
echo "🔧 Starting services..."
if ! docker-compose up -d; then
    echo "❌ Failed to start services"
    echo "💡 Tip: If port 5432 is in use, we've configured PostgreSQL to use port 5433 instead"
    exit 1
fi

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Create and migrate database
echo "🗄️  Creating and migrating database..."
if ! docker-compose exec web bash -c "mkdir -p test/dummy/db/migrate && cp db/migrate/*.rb test/dummy/db/migrate/ 2>/dev/null; cd test/dummy && rails db:create db:migrate"; then
    echo "❌ Failed to create/migrate database"
    echo "💡 Try running: docker-compose logs web"
    exit 1
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📍 Your application is now running:"
echo "   - Main site: http://localhost:3000"
echo "   - Admin panel: http://localhost:3000/admin"
echo "   - Articles: http://localhost:3000/articles"
echo "   - Products: http://localhost:3000/products"
echo ""
echo "💡 Useful commands:"
echo "   - View logs: docker-compose logs -f web"
echo "   - Access console: docker-compose exec web bash"
echo "   - Stop services: docker-compose down"
echo ""
echo "📝 To seed sample data, run:"
echo "   docker-compose exec web bash"
echo "   cd test/dummy && rails console"
echo "   # Then paste the seed data from DOCKER_SETUP.md"
echo ""

