# Logging Stack

Centralized log aggregation using Loki, Promtail, and Grafana.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Loki | 3100 | Log aggregation backend |
| Promtail | 9080 | Log shipping agent |
| Grafana | 3000 | Log visualization |
| Nginx | 8080 | Example app generating logs |

## Quick Start

```bash
docker compose up -d
```

- Grafana: http://localhost:3000 (admin / admin)
- Nginx: http://localhost:8080

After starting, add Loki as a data source in Grafana:
1. Go to Configuration > Data Sources > Add data source
2. Select Loki
3. Set URL to `http://loki:3100`
4. Click Save & Test

## Log Sources

- **System logs**: `/var/log/syslog`
- **Docker container logs**: All containers via Docker socket
- **Nginx access logs**: Parsed with regex labels (method, status)

## Architecture

```
System logs ─────┐
                 │
Docker logs ─────┼──► Promtail ──► Loki ──► Grafana
                 │
Nginx logs ──────┘
```

## Query Examples (LogQL)

```logql
# All nginx logs
{job="nginx"}

# 500 errors only
{job="nginx"} |= "500"

# Container logs by name
{job="docker", container_name="nginx-example"}

# Filter by level
{job="docker"} | json | level="error"
```
