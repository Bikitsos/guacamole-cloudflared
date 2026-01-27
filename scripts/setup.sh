#!/bin/bash
# ===========================================
# Guacamole Setup Script
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "  Guacamole + Cloudflared Setup Script"
echo "=========================================="

# Check for podman or docker
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    COMPOSE_CMD="podman-compose"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    COMPOSE_CMD="docker compose"
else
    echo "Error: Neither podman nor docker found. Please install one."
    exit 1
fi

echo "Using: $CONTAINER_CMD"

# Check if .env exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo ""
    echo "Creating .env file from template..."
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    
    # Generate a random password
    RANDOM_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)
    
    # Update the password in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/CHANGE_ME_STRONG_PASSWORD/$RANDOM_PASSWORD/" "$PROJECT_DIR/.env"
    else
        sed -i "s/CHANGE_ME_STRONG_PASSWORD/$RANDOM_PASSWORD/" "$PROJECT_DIR/.env"
    fi
    
    echo ""
    echo "=========================================="
    echo "  IMPORTANT: Configure .env file"
    echo "=========================================="
    echo ""
    echo "1. Edit $PROJECT_DIR/.env"
    echo "2. Set your CLOUDFLARE_TUNNEL_TOKEN"
    echo ""
    echo "To get a tunnel token:"
    echo "  - Go to https://one.dash.cloudflare.com/"
    echo "  - Navigate to Networks -> Tunnels"
    echo "  - Create a new tunnel"
    echo "  - Copy the token"
    echo ""
    echo "Generated PostgreSQL password: $RANDOM_PASSWORD"
    echo "(This has been saved to .env)"
    echo ""
    exit 0
fi

# Validate required variables
source "$PROJECT_DIR/.env"

if [ -z "$CLOUDFLARE_TUNNEL_TOKEN" ] || [ "$CLOUDFLARE_TUNNEL_TOKEN" == "YOUR_TUNNEL_TOKEN_HERE" ]; then
    echo "Error: CLOUDFLARE_TUNNEL_TOKEN is not set in .env"
    echo "Please configure it before running this script."
    exit 1
fi

echo ""
echo "Configuration validated. Starting services..."
echo ""

# Create necessary directories
mkdir -p "$PROJECT_DIR/guacamole-home"
mkdir -p "$PROJECT_DIR/init"

# Make init script executable
chmod +x "$PROJECT_DIR/init/01-init-db.sh"

# Pull images
echo "Pulling container images..."
cd "$PROJECT_DIR"
$COMPOSE_CMD pull

# Start services
echo ""
echo "Starting services..."
$COMPOSE_CMD up -d

echo ""
echo "=========================================="
echo "  Services Started!"
echo "=========================================="
echo ""
echo "Waiting for services to be healthy..."
sleep 10

# Check service status
$COMPOSE_CMD ps

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Access Guacamole through your Cloudflare tunnel URL"
echo ""
echo "Default credentials:"
echo "  Username: guacadmin"
echo "  Password: guacadmin"
echo ""
echo "IMPORTANT: Change the default password immediately!"
echo ""
echo "Useful commands:"
echo "  View logs:    $COMPOSE_CMD logs -f"
echo "  Stop:         $COMPOSE_CMD down"
echo "  Restart:      $COMPOSE_CMD restart"
echo ""
