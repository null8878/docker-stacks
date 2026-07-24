# Security Stack

Self-hosted security services: password management, intrusion prevention, and SSO/2FA.

## Services

| Service | Port | Description |
|---------|------|-------------|
| Vaultwarden | 8080 | Bitwarden-compatible password manager |
| CrowdSec | - | Crowd-sourced security intelligence |
| Authelia | 9091 | SSO and two-factor authentication |

## Quick Start

```bash
# Generate required secrets
export VAULTWARDEN_ADMIN_TOKEN=$(openssl rand -hex 32)
export AUTHELIA_JWT_SECRET=$(openssl rand -hex 32)

# Start the stack
docker compose up -d
```

- Vaultwarden: http://localhost:8080
- Authelia: http://localhost:9091

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | http://localhost:8080 | Vaultwarden base URL |
| `SIGNUPS_ALLOWED` | true | Allow new user registrations |
| `VAULTWARDEN_ADMIN_TOKEN` | - | Admin panel access token |
| `AUTHELIA_JWT_SECRET` | - | JWT signing secret |

### Vaultwarden

1. Access the web vault at http://localhost:8080
2. Create an admin account
3. Access admin panel at http://localhost:8080/admin with the admin token
4. Disable signups after creating accounts: `SIGNUPS_ALLOWED=false`

### SMTP Configuration

Update the SMTP settings in `docker-compose.yml` for email notifications:

```yaml
SMTP_HOST: smtp.gmail.com
SMTP_PORT: 587
SMTP_FROM: your-email@gmail.com
SMTP_USERNAME: your-email@gmail.com
SMTP_PASSWORD: your-app-password
SMTP_SECURITY: starttls
```

### CrowdSec

CrowdSec reads Docker logs and applies community-sourced threat intelligence:

```bash
# Check bouncer status
docker exec crowdsec cscli bouncers list

# Check decisions
docker exec crowdsec cscli decisions list

# Install a bouncer
docker exec crowdsec cscli bouncers add nginx-bouncer
```

### Authelia

Edit the configuration at `authelia_data/configuration.yml` to set up:
- Authentication providers (LDAP, file-based)
- Access control rules
- TOTP 2FA settings
- Session management

## Data Persistence

- `vaultwarden_data`: Password vault database and attachments
- `crowdsec_data`: Threat intelligence decisions and alerts
- `crowdsec_config`: CrowdSec configuration and bouncer credentials
- `authelia_data`: Authelia configuration and session data

## Security Notes

- Generate unique secrets for production: `openssl rand -hex 32`
- Vaultwarden uses client-side encryption (server never sees passwords)
- CrowdSec aggregates threat intelligence from the community
- Authelia provides per-service 2FA and SSO
