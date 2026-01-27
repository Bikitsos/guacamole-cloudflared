#!/bin/bash
# ===========================================
# Initialize Guacamole PostgreSQL Database
# ===========================================
# NOTE: This script is kept for reference but the postgres-alpine
# image doesn't have curl. Use scripts/init-db.sh instead to
# initialize the database after containers are running.

echo "=========================================="
echo "  Guacamole Database Setup"
echo "=========================================="
echo ""
echo "The database schema needs to be initialized manually."
echo "After 'podman-compose up -d', run:"
echo "  ./scripts/init-db.sh"
echo ""
echo "This will create the guacamole tables and default admin user."
echo ""
