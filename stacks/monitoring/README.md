# Monitoring Stack

Full observability stack with Prometheus, Grafana, Node Exporter, cAdvisor, and Alertmanager.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Prometheus | 9090 | Metrics collection and storage |
| Grafana | 3000 | Dashboards and visualization |
| Node Exporter | 9100 | Host-level metrics |
| cAdvisor | 8080 | Container metrics |
| Alertmanager | 9093 | Alert routing and notifications |

## Quick Start

```bash
docker compose up -d
```

- Grafana: http://localhost:3000 (admin / admin)
- Prometheus: http://localhost:9090

## Configuration

### Environment Variables

Create a `.env` file:

```bash
GRAFANA_PASSWORD=your-secure-password
```

### Alertmanager

Edit `alertmanager.yml` to configure notification channels (Slack, PagerDuty, email).

### Alert Rules

Edit `alerts.yml` to customize alert thresholds. Pre-configured rules:

- CPU usage > 85% for 5 minutes
- Memory usage > 85% for 5 minutes
- Disk space < 15% for 5 minutes
- Container down for 2 minutes
- Container restarting > 3 times/hour

## Architecture

```
Node Exporter ──┐
                │
cAdvisor ───────┼──► Prometheus ──► Alertmanager
                │        │
Grafana ◄───────┘        └──► Storage (30d retention)
```

## Data Persistence

- `prometheus_data`: Time-series metrics (30-day retention)
- `grafana_data`: Dashboards, users, settings
- `alertmanager_data`: Alert silences and inhibition state
