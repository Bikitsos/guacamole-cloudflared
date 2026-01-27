#!/bin/bash
# ===========================================
# Generate Guacamole Database Schema
# ===========================================
# Run this script if automatic initialization fails
# It will generate SQL files that can be manually imported

set -e

GUACAMOLE_VERSION="1.5.5"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/init/sql"

echo "=========================================="
echo "  Generating Guacamole DB Schema"
echo "=========================================="

# Check for podman or docker
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
else
    echo "Error: Neither podman nor docker found."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Generating PostgreSQL schema using guacamole container..."

# Generate schema using the guacamole container
$CONTAINER_CMD run --rm docker.io/guacamole/guacamole:latest \
    /opt/guacamole/bin/initdb.sh --postgresql > "$OUTPUT_DIR/guacamole-schema.sql"

echo ""
echo "Schema generated: $OUTPUT_DIR/guacamole-schema.sql"
echo ""
echo "To manually initialize the database:"
echo "  1. Start only the database: podman-compose up -d guacamole-db"
echo "  2. Wait for it to be ready"
echo "  3. Run: podman exec -i guacamole-db psql -U guacamole_user -d guacamole_db < $OUTPUT_DIR/guacamole-schema.sql"
echo ""
