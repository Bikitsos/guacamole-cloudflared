# Guacamole with Cloudflare Tunnel

Apache Guacamole deployment with Cloudflare Tunnel for secure remote access, including printing and file upload/download support.

## Features

- 🖥️ **Apache Guacamole** - Clientless remote desktop gateway
- 🔒 **Cloudflare Tunnel** - Secure access without exposing ports
- 🖨️ **Printing Support** - Print from remote sessions to PDF
- 📁 **File Transfer** - Upload and download files to/from remote sessions
- 🐘 **PostgreSQL** - Persistent database for user management
- 📹 **Session Recording** - Optional session recording support
- 🛡️ **Brute Force Protection** - Native login attempt limiting

## Prerequisites

- Podman or Docker installed
- Podman Compose or Docker Compose
- Cloudflare account with a domain
- Cloudflare Tunnel token

## Quick Start

### 1. Clone/Setup

```bash
cd /path/to/guacamole-cloudflared
```

### 2. Run Setup Script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

On first run, this will create `.env` from the template. Edit it to add your Cloudflare tunnel token.

### 3. Configure Cloudflare Tunnel

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigate to **Networks** → **Tunnels**
3. Click **Create a tunnel**
4. Choose **Cloudflared** connector
5. Name your tunnel (e.g., "guacamole")
6. Copy the tunnel token
7. Paste it in your `.env` file as `CLOUDFLARE_TUNNEL_TOKEN`

### 4. Configure Tunnel Route

In the Cloudflare dashboard, add a public hostname for your tunnel:

| Field | Value |
|-------|-------|
| Subdomain | `guacamole` (or your choice) |
| Domain | Your domain |
| Service Type | `HTTP` |
| URL | `guacamole:8080` |
| Path | `/guacamole/` |

### 5. Start Services

```bash
./scripts/setup.sh
```

### 6. Access Guacamole

Navigate to `https://guacamole.yourdomain.com/guacamole/`

**Default credentials:**
- Username: `guacadmin`
- Password: `guacadmin`

⚠️ **Change the default password immediately after first login!**

## File Structure

```
guacamole-cloudflared/
├── docker-compose.yml      # Main compose file
├── .env                    # Environment configuration (git-ignored)
├── .env.example            # Environment template
├── .gitignore              # Git ignore rules
├── guacamole-home/         # Guacamole configuration
│   └── guacamole.properties
├── init/                   # Database initialization
│   └── 01-init-db.sh
├── scripts/
│   ├── setup.sh            # Setup script
│   └── generate-db-schema.sh
└── README.md
```

## Configuration

### Brute Force Protection

Native brute force protection is enabled by default in `guacamole.properties`:

| Setting | Default | Description |
|---------|---------|-------------|
| `api-max-login-attempts` | 5 | Failed attempts before lockout |
| `api-lockout-duration` | 300 | Lockout duration in seconds (5 min) |
| `api-max-login-attempts-period` | 60 | Time window for counting failures |

After 5 failed login attempts within 60 seconds, the IP is locked out for 5 minutes.

### Enabling Printing

Printing is enabled by default. When you print from a remote session:

1. The print job is converted to PDF
2. PDFs are saved to the `/print` volume
3. Download the PDF from the Guacamole interface

To use printing in a connection:
1. Edit the connection settings
2. Under "Device Redirection", enable "Printing"
3. Set the printer name (optional)

### Enabling File Transfer

File transfer (drive redirection) is enabled by default:

**For RDP connections:**
1. Edit the connection
2. Under "Device Redirection", enable "Drive"
3. Set drive path (default: `/drive`)
4. Files appear as a network drive in the remote session

**For SSH/SFTP connections:**
1. Use the file browser in the Guacamole sidebar
2. Upload/download files directly

### Connection Parameters for Printing & File Transfer

When creating connections, you can configure these parameters:

#### RDP Connections

| Parameter | Value | Description |
|-----------|-------|-------------|
| `enable-drive` | `true` | Enable file transfer |
| `drive-path` | `/drive/username` | Path for user files |
| `create-drive-path` | `true` | Auto-create directory |
| `enable-printing` | `true` | Enable PDF printing |
| `printer-name` | `Guacamole` | Printer name shown |

#### SSH Connections

| Parameter | Value | Description |
|-----------|-------|-------------|
| `enable-sftp` | `true` | Enable SFTP file transfer |
| `sftp-root-directory` | `/home/user` | Root directory for SFTP |

## Managing Services

```bash
# View logs
podman-compose logs -f

# View specific service logs
podman-compose logs -f guacamole
podman-compose logs -f cloudflared

# Restart services
podman-compose restart

# Stop services
podman-compose down

# Stop and remove volumes (WARNING: deletes data)
podman-compose down -v

# Update images
podman-compose pull
podman-compose up -d
```

## Troubleshooting

### Database Initialization Failed

If the automatic database initialization fails:

```bash
# Generate schema manually
./scripts/generate-db-schema.sh

# Then import it
podman exec -i guacamole-db psql -U guacamole_user -d guacamole_db < init/sql/guacamole-schema.sql
```

### Cannot Connect Through Tunnel

1. Check cloudflared logs: `podman-compose logs cloudflared`
2. Verify tunnel token is correct in `.env`
3. Ensure tunnel route is configured in Cloudflare dashboard
4. Check that the service URL is `guacamole:8080`

### Guacamole Shows "Error" on Connection

1. Check guacd logs: `podman-compose logs guacd`
2. Verify the target machine is reachable from the container network
3. For RDP: Ensure RDP is enabled on the target and firewall allows connections

### Printing Not Working

1. Ensure `enable-printing: true` in connection settings
2. Check that the print volume has correct permissions
3. Verify printing is enabled in `guacamole.properties`

### File Transfer Not Working

1. Enable drive/SFTP in connection settings
2. Check volume permissions
3. For RDP: The drive appears as a network location, not a local drive

## Security Recommendations

1. **Change default password** immediately after first login
2. **Enable TOTP** two-factor authentication
3. **Use strong passwords** for database and admin accounts
4. **Configure Cloudflare Access** policies for additional protection
5. **Regularly update** container images
6. **Monitor logs** for suspicious activity

## Backup

### Database Backup

```bash
podman exec guacamole-db pg_dump -U guacamole_user guacamole_db > backup.sql
```

### Restore Database

```bash
podman exec -i guacamole-db psql -U guacamole_user -d guacamole_db < backup.sql
```

## License

This deployment configuration is provided as-is. Apache Guacamole is licensed under the Apache License 2.0.
