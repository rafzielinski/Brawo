@echo off
echo 🚀 Setting up BrawoCMS Development Environment
echo ==============================================
echo.

REM Build Docker containers
echo 📦 Building Docker containers...
docker-compose build

REM Start services
echo 🔧 Starting services...
docker-compose up -d

REM Wait for database to be ready
echo ⏳ Waiting for database to be ready...
timeout /t 5 /nobreak

REM Create and migrate database
echo 🗄️  Creating and migrating database...
docker-compose exec web bash -c "cd test/dummy && rails db:create db:migrate"

echo.
echo ✅ Setup complete!
echo.
echo 📍 Your application is now running:
echo    - Main site: http://localhost:3000
echo    - Admin panel: http://localhost:3000/admin
echo    - Articles: http://localhost:3000/articles
echo    - Products: http://localhost:3000/products
echo.
echo 💡 Useful commands:
echo    - View logs: docker-compose logs -f web
echo    - Access console: docker-compose exec web bash
echo    - Stop services: docker-compose down
echo.

