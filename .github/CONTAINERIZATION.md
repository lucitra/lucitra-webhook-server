# Containerization Best Practices

## Docker Image Guidelines

### 1. Multi-Stage Builds

Our Dockerfile uses multi-stage builds to minimize final image size:

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "src/index.js"]
```

### 2. Security Best Practices

- ✅ Use specific image tags (not `latest`)
- ✅ Run as non-root user
- ✅ Scan images for vulnerabilities
- ✅ Minimize attack surface (Alpine Linux)
- ✅ Don't store secrets in images

### 3. Image Optimization

- Use `.dockerignore` to exclude unnecessary files
- Combine RUN commands to reduce layers
- Order Dockerfile commands from least to most frequently changing
- Remove package managers and build tools in final stage

## Container Registry

### GitHub Container Registry (ghcr.io)

Images are automatically pushed to:
```
ghcr.io/lucitra/lucitra-webhook-server:<tag>
```

### Image Tags

- `develop` - Latest development build
- `staging` - Latest staging build  
- `main` - Latest production build
- `develop-<sha>` - Specific commit builds
- `v1.2.3` - Semantic version releases

### Pulling Images

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull specific image
docker pull ghcr.io/lucitra/lucitra-webhook-server:develop

# Run container locally
docker run -p 3000:3000 ghcr.io/lucitra/lucitra-webhook-server:develop
```

## Local Development

### Using Docker Compose

```bash
# Start all services
docker-compose up

# Rebuild and start
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Environment Variables

Use `.env` files for local development:

```bash
# .env.local
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
```

Never commit `.env` files containing secrets!

## Health Checks

### Dockerfile Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"
```

### Kubernetes/Cloud Run Health Checks

Configure in your deployment:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Resource Management

### Container Resources

Set appropriate resource limits:

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Monitoring

- Monitor container metrics (CPU, memory, network)
- Set up alerts for resource exhaustion
- Use horizontal pod autoscaling for Kubernetes

## Troubleshooting

### Debug Running Containers

```bash
# View running containers
docker ps

# View container logs
docker logs <container-id>

# Execute commands in container
docker exec -it <container-id> sh

# Inspect container
docker inspect <container-id>
```

### Common Issues

1. **Container exits immediately**
   - Check logs: `docker logs <container-id>`
   - Verify CMD/ENTRYPOINT syntax
   - Ensure process doesn't exit

2. **Cannot connect to container**
   - Check port mapping: `-p host:container`
   - Verify service is listening on 0.0.0.0
   - Check firewall rules

3. **Image build fails**
   - Check Docker daemon is running
   - Verify network connectivity
   - Clear Docker cache: `docker system prune`

## CI/CD Integration

### Automated Building

The CI/CD pipeline automatically:
1. Builds images on every push
2. Tags with branch and commit SHA
3. Pushes to container registry
4. Scans for vulnerabilities

### Deployment

Images are deployed to:
- **Development**: Cloud Run (GCP)
- **Staging**: Cloud Run (GCP)
- **Production**: Cloud Run (GCP) / ECS (AWS)

## Best Practices Summary

1. **Keep images small** - Use Alpine Linux, multi-stage builds
2. **Layer caching** - Order Dockerfile efficiently
3. **Security first** - Scan images, run as non-root
4. **Version everything** - Tag images properly
5. **Health checks** - Implement proper health endpoints
6. **Resource limits** - Set appropriate constraints
7. **Logging** - Centralize container logs
8. **Monitoring** - Track metrics and set alerts