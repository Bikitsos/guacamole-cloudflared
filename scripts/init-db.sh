#!/bin/bash
# ===========================================
# Initialize Guacamole PostgreSQL Database
# ===========================================
# This script generates and imports the Guacamole schema

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "  Initializing Guacamole Database Schema"
echo "=========================================="

# Check for podman or docker
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    COMPOSE_CMD="podman-compose"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    COMPOSE_CMD="docker compose"
else
    echo "Error: Neither podman nor docker found."
    exit 1
fi

# Load environment
source "$PROJECT_DIR/.env"

# Generate the schema SQL
echo "Generating database schema..."
mkdir -p "$PROJECT_DIR/init/sql"

$CONTAINER_CMD run --rm docker.io/guacamole/guacamole:latest \
    /opt/guacamole/bin/initdb.sh --postgresql > "$PROJECT_DIR/init/sql/guacamole-schema.sql"

echo "Schema generated: $PROJECT_DIR/init/sql/guacamole-schema.sql"

# Import the schema
echo "Importing schema into database..."
$CONTAINER_CMD exec -i guacamole-db psql -U "${POSTGRES_USER:-guacamole_user}" -d "${POSTGRES_DB:-guacamole_db}" \
    < "$PROJECT_DIR/init/sql/guacamole-schema.sql"

echo ""
echo "=========================================="
echo "  Database Initialized Successfully!"
echo "=========================================="
echo ""
echo "Default credentials:"
echo "  Username: guacadmin"
echo "  Password: guacadmin"
echo ""
echo "Restart Guacamole to apply changes:"
echo "  $COMPOSE_CMD restart guacamole"
echo ""
