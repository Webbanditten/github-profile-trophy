# Docker Deployment Guide

This guide explains how to run GitHub Profile Trophy using Docker on your self-hosted server.

## Quick Start with Pre-built Image

The easiest way to run this project is using the pre-built Docker image from GitHub Container Registry:

```bash
# Pull the latest image
docker pull ghcr.io/OWNER/github-profile-trophy:latest

# Run with docker-compose
docker-compose up -d
```

## Configuration

### 1. Create Environment File

Copy the example environment file and configure it:

```bash
cp .env.docker .env
```

### 2. Configure GitHub Token

Edit `.env` and add your GitHub Personal Access Token:

```env
GITHUB_TOKEN1=ghp_your_token_here
```

**Get a GitHub Token:**
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `public_repo`, `read:user`
4. Copy the generated token

### 3. Optional: Configure Redis

Redis is enabled by default for caching. To disable:

```env
ENABLE_REDIS=false
```

## Running with Docker Compose

The `docker-compose.yml` file includes both the application and Redis:

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

## Running with Docker Run

If you prefer using `docker run` directly:

```bash
# Create a network
docker network create trophy-network

# Run Redis
docker run -d \
  --name trophy-redis \
  --network trophy-network \
  -p 6379:6379 \
  redis:alpine

# Run the app
docker run -d \
  --name trophy-app \
  --network trophy-network \
  -p 8000:8080 \
  -e PORT=8080 \
  -e GITHUB_TOKEN1=your_token_here \
  -e GITHUB_API=https://api.github.com/graphql \
  -e ENABLE_REDIS=true \
  -e REDIS_HOST=trophy-redis \
  -e REDIS_PORT=6379 \
  ghcr.io/OWNER/github-profile-trophy:latest
```

## Accessing the Service

Once running, access the service at:

```
http://localhost:8000/?username=YOUR_GITHUB_USERNAME
```

Example:
```
http://localhost:8000/?username=ryo-ma&theme=onedark&column=3
```

## Building Your Own Image

If you want to build the image yourself:

```bash
# Build the image
docker build -t github-profile-trophy .

# Run with your custom image
docker-compose up -d
```

## Production Deployment

### Using a Reverse Proxy (Nginx)

Example Nginx configuration:

```nginx
server {
    listen 80;
    server_name trophies.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Using Traefik

Add labels to docker-compose.yml:

```yaml
services:
  app:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.trophy.rule=Host(`trophies.yourdomain.com`)"
      - "traefik.http.routers.trophy.entrypoints=websecure"
      - "traefik.http.routers.trophy.tls.certresolver=myresolver"
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Application port | `8080` |
| `GITHUB_TOKEN1` | GitHub Personal Access Token | _(required)_ |
| `GITHUB_TOKEN2` | Additional token for rate limiting | _(optional)_ |
| `GITHUB_API` | GitHub API endpoint | `https://api.github.com/graphql` |
| `ENABLE_REDIS` | Enable Redis caching | `true` |
| `REDIS_HOST` | Redis hostname | `redis` |
| `REDIS_PORT` | Redis port | `6379` |
| `REDIS_USERNAME` | Redis username | _(optional)_ |
| `REDIS_PASSWORD` | Redis password | _(optional)_ |

## Updating

To update to the latest version:

```bash
# Pull the latest image
docker-compose pull

# Restart services
docker-compose up -d
```

## Troubleshooting

### Port Already in Use

If port 8000 is already in use, change it in `docker-compose.yml`:

```yaml
ports:
  - "9000:8080"  # Change 8000 to any available port
```

### GitHub API Rate Limiting

Add multiple GitHub tokens to increase rate limits:

```env
GITHUB_TOKEN1=token1_here
GITHUB_TOKEN2=token2_here
```

### Check Container Logs

```bash
# View app logs
docker-compose logs -f app

# View Redis logs
docker-compose logs -f redis
```

### Reset Redis Cache

```bash
# Restart Redis to clear cache
docker-compose restart redis

# Or remove the volume completely
docker-compose down -v
```

## Resource Requirements

**Minimum:**
- CPU: 1 core
- RAM: 512 MB
- Disk: 1 GB

**Recommended:**
- CPU: 2 cores
- RAM: 1 GB
- Disk: 5 GB (for Redis persistence)

## Security Considerations

1. **Never commit `.env` file** - It contains sensitive tokens
2. **Use environment variables** for secrets in production
3. **Keep tokens secure** - Rotate them regularly
4. **Use HTTPS** in production with a reverse proxy
5. **Update regularly** - Pull latest images for security patches

## Support

For issues and questions:
- GitHub Issues: https://github.com/ryo-ma/github-profile-trophy/issues
- Documentation: See README.md for API parameters
