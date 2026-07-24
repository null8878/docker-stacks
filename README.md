# Docker Stacks — Production-Ready Docker Compose Templates

A curated collection of production-grade Docker Compose stacks for common infrastructure patterns. Each stack is self-contained, documented, and ready to deploy.

## Stacks

| Stack | Description | Services |
|-------|-------------|----------|
| [monitoring](stacks/monitoring/) | Full observability stack with metrics, dashboards, and alerting | Prometheus, Grafana, Node Exporter, cAdvisor, Alertmanager |
| [logging](stacks/logging/) | Centralized log aggregation with Loki | Loki, Promtail, Grafana, Nginx |
| [webapp](stacks/webapp/) | Production web application with SSL and HA | Nginx, Node.js, PostgreSQL, Redis, Certbot |
| [dev-environment](stacks/dev-environment/) | Local development with databases and tooling | PostgreSQL, Redis, MongoDB, Adminer, MailHog, MinIO, Portainer |
| [ci-cd](stacks/ci-cd/) | Self-hosted CI/CD pipeline | Gitea, Woodpecker CI, PostgreSQL, Container Registry |
| [security](stacks/security/) | Self-hosted security and auth services | Vaultwarden, CrowdSec, Authelia |

## Quick Start

```bash
# Clone and enter the repository
cd /tmp/docker-stacks

# Deploy any stack
docker compose -f stacks/monitoring/docker-compose.yml up -d

# Use the deploy script with environment selection
./scripts/deploy.sh monitoring dev
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Host / VM                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │
│  │  Monitoring  │  │   Logging   │  │  Web App   │  │
│  │  ┌────────┐ │  │  ┌────────┐ │  │  ┌──────┐  │  │
│  │  │Grafana │ │  │  │Grafana │ │  │  │Nginx │  │  │
│  │  └───┬────┘ │  │  └────────┘ │  │  └──┬───┘  │  │
│  │      │      │  │  ┌────────┐ │  │     │      │  │
│  │  ┌───┴────┐ │  │  │  Loki  │ │  │  ┌──┴───┐  │  │
│  │  │Prom   │ │  │  └────────┘ │  │  │Node.js│  │  │
│  │  └───┬────┘ │  │  ┌────────┐ │  │  └──┬───┘  │  │
│  │      │      │  │  │Promtail│ │  │  ┌──┴───┐  │  │
│  │  ┌───┴────┐ │  │  └────────┘ │  │  │ PG   │  │  │
│  │  │Export. │ │  └─────────────┘  │  └──────┘  │  │
│  │  └────────┘ │                   │  ┌──────┐  │  │
│  └─────────────┘                   │  │Redis │  │  │
│                                    │  └──────┘  │  │
│  ┌─────────────┐                   └────────────┘  │
│  │    CI/CD    │  ┌─────────────┐                   │
│  │  ┌───────┐  │  │  Security   │                   │
│  │  │ Gitea │  │  │ ┌─────────┐ │                   │
│  │  └───┬───┘  │  │ │Vault.   │ │                   │
│  │  ┌───┴───┐  │  │ └─────────┘ │                   │
│  │  │WP CI │  │  │ ┌─────────┐ │                   │
│  │  └───────┘  │  │ │CrowdSec │ │                   │
│  └─────────────┘  │ └─────────┘ │                   │
│                   └─────────────┘                   │
└─────────────────────────────────────────────────────┘
```

## Scripts

| Script | Description |
|--------|-------------|
| [backup.sh](scripts/backup.sh) | Backup all databases and volumes |
| [health-check.sh](scripts/health-check.sh) | Health check across all running stacks |
| [deploy.sh](scripts/deploy.sh) | Deploy a stack with environment selection (dev/prod) |

## Conventions

- All stacks use named Docker networks for inter-stack communication
- Persistent data stored in named volumes
- Environment variables sourced from `.env` files (never committed)
- Health checks configured on all services
- Resource limits set for production use
- Logging configured with `json-file` driver and size limits

## Security Notes

- Never commit `.env` files — they're in `.gitignore`
- Use Docker secrets for sensitive data in production
- All services bind to internal networks only
- CrowdSec provides crowd-sourced threat intelligence
- Authelia provides SSO and two-factor authentication

## Requirements

- Docker Engine 24.0+
- Docker Compose v2.20+
- 4GB+ RAM recommended
- 20GB+ disk for all stacks

## License

MIT
