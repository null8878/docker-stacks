# CI/CD Stack

Self-hosted CI/CD pipeline with Gitea, Woodpecker CI, and a container registry.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Gitea | 3000 | Self-hosted Git service |
| Woodpecker Server | 8000 | CI/CD server |
| Woodpecker Agent | - | CI/CD build agent |
| PostgreSQL | 5432 | Gitea database |
| Registry | 5000 | Container image registry |

## Quick Start

```bash
# 1. Start the stack
docker compose up -d

# 2. Create admin user in Gitea
docker compose exec gitea gitea admin user create \
  --username admin \
  --password admin123 \
  --email admin@example.com \
  --admin

# 3. Register an OAuth2 app in Gitea:
#    Go to http://localhost:3000 → Settings → Applications
#    Name: Woodpecker
#    Redirect URI: http://localhost:8000/login

# 4. Set environment variables
export GITEA_OAUTH_CLIENT_ID=your_client_id
export GITEA_OAUTH_CLIENT_SECRET=your_client_secret
export WOODPECKER_AGENT_SECRET=your_agent_secret

# 5. Restart with credentials
docker compose up -d
```

## Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Gitea | http://localhost:3000 | admin / admin123 |
| Woodpecker | http://localhost:8000 | (via Gitea OAuth) |
| Registry | http://localhost:5000 | - |

## Pipeline Example

Create `.woodpecker.yml` in your Gitea repository:

```yaml
pipeline:
  build:
    image: node:22-alpine
    commands:
      - npm install
      - npm test

  docker:
    image: plugins/docker
    settings:
      repo: registry:5000/myapp
      registry: registry:5000
      insecure: true
    when:
      event: push
      branch: main
```

## Configuration

### OAuth Setup

1. In Gitea, go to Settings > Applications
2. Create OAuth2 Application:
   - Name: `Woodpecker CI`
   - Redirect URI: `http://localhost:8000/login`
3. Copy Client ID and Client Secret
4. Set as environment variables

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GITEA_OAUTH_CLIENT_ID` | - | OAuth client ID from Gitea |
| `GITEA_OAUTH_CLIENT_SECRET` | - | OAuth client secret |
| `WOODPECKER_AGENT_SECRET` | changeme | Shared secret between server and agent |

## Data Persistence

- `gitea_data`: Repositories, configuration, database
- `postgres_data`: Gitea PostgreSQL data
- `woodpecker_data`: CI/CD pipelines and logs
- `woodpecker_agent_data`: Agent workspace
- `registry_data`: Container images
