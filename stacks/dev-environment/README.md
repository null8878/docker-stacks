# Development Environment Stack

Local development stack with databases, email testing, S3 storage, and management UIs.

## Services

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | 5432 | Relational database |
| Redis | 6379 | In-memory cache / message broker |
| MongoDB | 27017 | Document database |
| Adminer | 8080 | Database management UI |
| MailHog | 8025 (UI) / 1025 (SMTP) | Email testing |
| MinIO | 9000 (API) / 9001 (Console) | S3-compatible object storage |
| Portainer | 9443 | Docker management UI |

## Quick Start

```bash
docker compose up -d
```

## Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Adminer | http://localhost:8080 | devuser / devpass |
| MailHog | http://localhost:8025 | - |
| MinIO Console | http://localhost:9001 | minioadmin / minioadmin |
| Portainer | https://localhost:9443 | (set on first login) |

### Adminer Login

- **System**: PostgreSQL
- **Server**: postgres
- **Username**: devuser
- **Password**: devpass
- **Database**: devdb

### SMTP Configuration (for MailHog)

```
Host: mailhog
Port: 1025
TLS: None
```

## Configuration

### Application .env

```bash
DATABASE_URL=postgresql://devuser:devpass@postgres:5432/devdb
REDIS_URL=redis://redis:6379
MONGO_URL=mongodb://devuser:devpass@mongo:27017/devdb?authSource=admin
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
SMTP_HOST=mailhog
SMTP_PORT=1025
```

## Data Persistence

All data persists across restarts in named volumes:
- `postgres_data`: PostgreSQL data
- `redis_data`: Redis AOF persistence
- `mongo_data`: MongoDB data files
- `minio_data`: S3 object storage
- `portainer_data`: Portainer settings
