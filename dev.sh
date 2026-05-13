#!/bin/bash
# Development helper script for Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Matches docker-compose.yml service name `web`
run_in_container() {
  docker-compose run --rm web "$@"
}

run_test() {
  docker-compose run --rm web "$@"
}

DUMMY="cd /app/test/dummy"

case "$1" in
  build)
    echo -e "${GREEN}Building Docker image...${NC}"
    docker-compose build
    ;;

  setup)
    echo -e "${GREEN}Setting up development environment...${NC}"
    docker-compose build
    run_in_container bash -lc "cd /app && bundle install"
    echo -e "${GREEN}Setting up test database...${NC}"
    run_test bash -lc "cd /app && bundle install && ${DUMMY} && RAILS_ENV=test bundle exec rake db:create db:migrate"
    ;;

  console)
    echo -e "${GREEN}Starting Rails console...${NC}"
    run_in_container bash -lc "cd /app && bundle install && ${DUMMY} && bundle exec rails console"
    ;;

  test)
    echo -e "${GREEN}Running tests...${NC}"
    if [ -z "$2" ]; then
      run_test bash -lc "cd /app && bundle install && bundle exec rspec"
    else
      run_test bash -lc "cd /app && bundle install && bundle exec rspec $2"
    fi
    ;;

  shell)
    echo -e "${GREEN}Opening shell in container...${NC}"
    run_in_container bash -lc "cd /app && bash"
    ;;

  server)
    echo -e "${GREEN}Starting stack (use Ctrl+C to stop). Prefer: docker compose up${NC}"
    docker-compose up
    ;;

  migrate)
    echo -e "${GREEN}Running migrations...${NC}"
    run_test bash -lc "cd /app && bundle install && ${DUMMY} && bundle exec rake db:migrate"
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
    echo "  setup     - Initial setup (build, install deps, test DB)"
    echo "  console   - Rails console (dummy app)"
    echo "  test      - Run RSpec (optional path: ./dev.sh test spec/models)"
    echo "  shell     - Bash in project root (/app)"
    echo "  server    - docker compose up (web + db)"
    echo "  migrate   - Run dummy db:migrate"
    echo "  clean     - docker compose down -v + prune"
    exit 1
    ;;
esac
