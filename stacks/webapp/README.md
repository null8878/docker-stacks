# Web Application Stack

Production web app with Nginx reverse proxy, Node.js backend, PostgreSQL, Redis, and Let's Encrypt SSL.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Nginx | 80, 443 | Reverse proxy with SSL termination |
| App (Node.js) | 3000 | Application backend |
| PostgreSQL | 5432 | Primary database |
| Redis | 6379 | Caching layer |
| Certbot | - | Let's Encrypt SSL renewal |

## Quick Start

```bash
# Create .env file
cat > .env << EOF
POSTGRES_USER=appuser
POSTGRES_PASSWORD=changeme
POSTGRES_DB=webapp
NODE_ENV=production
DOMAIN=localhost
EOF

docker compose up -d
```

### SSL Setup (Production)

```bash
# Start with HTTP only first
docker compose up -d nginx

# Request certificate
docker compose run --rm certbot certonly \
  --webroot -w /var/www/certbot \
  -d yourdomain.com \
  --email admin@yourdomain.com \
  --agree-tos --no-eff-email

# Uncomment HTTPS server block in nginx.conf
# Restart nginx
docker compose restart nginx
```

## Architecture

```
Client ──► Nginx (80/443) ──► App (Node.js)
                     │              │
                     │              ├──► PostgreSQL
                     │              │
                     │              └──► Redis (cache)
                     │
                     └──► Let's Encrypt
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | appuser | Database user |
| `POSTGRES_PASSWORD` | changeme | Database password |
| `POSTGRES_DB` | webapp | Database name |
| `NODE_ENV` | production | Application environment |
| `DOMAIN` | localhost | Server domain name |

### Nginx Tuning

- Worker connections: 1024
- Gzip compression enabled
- Rate limiting: 10 req/s with burst of 20
- Keepalive timeout: 65s
- Client max body size: 10MB

## Data Persistence

- `postgres_data`: Database files
- `redis_data`: Cache and AOF data
- `app_data`: Application files
- `certbot_data`: SSL certificates
