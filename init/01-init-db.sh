#!/bin/bash
# ===========================================
# Initialize Guacamole PostgreSQL Database
# ===========================================
# This script runs automatically on first container start
# It downloads and executes the Guacamole database schema

set -e

GUACAMOLE_VERSION="1.5.5"

echo "Initializing Guacamole database schema..."

# Download the Guacamole JDBC extension to get the schema
cd /tmp
curl -SLO "https://apache.org/dyn/closer.lua/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz?action=download" \
    -o guacamole-auth-jdbc.tar.gz || \
curl -SLO "https://archive.apache.org/dist/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz" \
    -o guacamole-auth-jdbc.tar.gz

tar -xzf guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz

# Execute the schema files
PGPASSWORD="${POSTGRES_PASSWORD}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -f "/tmp/guacamole-auth-jdbc-${GUACAMOLE_VERSION}/postgresql/schema/001-create-schema.sql"

PGPASSWORD="${POSTGRES_PASSWORD}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -f "/tmp/guacamole-auth-jdbc-${GUACAMOLE_VERSION}/postgresql/schema/002-create-admin-user.sql"

echo "Guacamole database initialized successfully!"
echo "Default credentials: guacadmin / guacadmin"
echo "IMPORTANT: Change the default password immediately after first login!"

# Cleanup
rm -rf /tmp/guacamole-auth-jdbc*

echo "Database initialization complete."
