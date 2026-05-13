#!/bin/bash
# Development helper script for Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run commands in container
run_in_container() {
  docker-compose run --rm brawo_cms "$@"
}

# Function to run commands in test container
run_test() {
  docker-compose run --rm test "$@"
}

case "$1" in
  build)
    echo -e "${GREEN}Building Docker image...${NC}"
    docker-compose build
    ;;
    
  setup)
    echo -e "${GREEN}Setting up development environment...${NC}"
    docker-compose build
    run_in_container bundle install
    echo -e "${GREEN}Setting up test database...${NC}"
    run_test bash -c "cd spec/dummy && RAILS_ENV=test bundle exec rake db:create db:migrate"
    ;;
    
  console)
    echo -e "${GREEN}Starting Rails console...${NC}"
    run_in_container bash -c "cd spec/dummy && rails console"
    ;;
    
  test)
    echo -e "${GREEN}Running tests...${NC}"
    if [ -z "$2" ]; then
      run_test bundle exec rspec
    else
      run_test bundle exec rspec "$2"
    fi
    ;;
    
  shell)
    echo -e "${GREEN}Opening shell in container...${NC}"
    run_in_container bash
    ;;
    
  server)
    echo -e "${GREEN}Starting Rails server...${NC}"
    run_in_container bash -c "cd spec/dummy && rails server -b 0.0.0.0"
    ;;
    
  migrate)
    echo -e "${GREEN}Running migrations...${NC}"
    run_test bash -c "cd spec/dummy && RAILS_ENV=test bundle exec rake db:migrate"
    ;;
    
  clean)
    echo -e "${YELLOW}Cleaning up Docker resources...${NC}"
    docker-compose down -v
    docker system prune -f
    ;;
    
  *)
    echo "Usage: ./dev.sh {build|setup|console|test|shell|server|migrate|clean}"
    echo ""
    echo "Commands:"
    echo "  build     - Build Docker image"
    echo "  setup     - Initial setup (build, install deps, setup DB)"
    echo "  console   - Open Rails console in dummy app"
    echo "  test      - Run tests (optionally: ./dev.sh test spec/models)"
    echo "  shell     - Open bash shell in container"
    echo "  server    - Start Rails server for dummy app"
    echo "  migrate   - Run database migrations"
    echo "  clean     - Clean up Docker resources"
    exit 1
    ;;
esac

