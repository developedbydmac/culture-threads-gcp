# Culture Threads API

A Node.js REST API for the Culture Threads platform - a community-driven application for cultural exchange and storytelling.

## Features

- 🚀 Express.js REST API
- 🔒 Security headers with Helmet.js
- 🌐 CORS configuration
- 📊 Health check endpoint
- 🐳 Docker containerization
- ☸️ Kubernetes deployment manifests
- 🧪 Jest testing suite
- 🔄 CI/CD with GitHub Actions
- 📈 Production-ready logging

## Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test
```

### Docker

```bash
# Build image
docker build -t culture-threads-api .

# Run container
docker run -p 3000:3000 culture-threads-api
```

### Kubernetes

```bash
# Apply manifests
kubectl apply -f k8s/apps/
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information |
| `/health` | GET | Health check |
| `/api/threads` | GET | Get all threads |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `NODE_ENV` | Environment | `development` |
| `ALLOWED_ORIGINS` | CORS origins | `http://localhost:3000` |

## Health Check

The `/health` endpoint returns:

```json
{
  "status": "healthy",
  "timestamp": "2024-01-20T10:30:00.000Z",
  "version": "1.0.0",
  "environment": "production"
}
```

## Docker Security Features

- 🔒 Non-root user execution
- 📋 Multi-stage build (production ready)
- 🏥 Built-in health checks
- 🎯 Minimal attack surface

## Kubernetes Features

- 🔄 Rolling updates
- 📊 Resource limits and requests
- 🏥 Liveness and readiness probes
- 🔒 Security contexts
- 📦 ConfigMaps and Secrets
- 🌐 Ingress with SSL termination
- 📈 Pod anti-affinity for high availability

## CI/CD Pipeline

The project includes GitHub Actions workflows for:

- 🔍 Security scanning (TFSec, Checkov, Trivy)
- 🧪 Automated testing
- 🐳 Container image building
- 🚀 Deployment to GKE
- 📊 Infrastructure validation

## Development Workflow

1. Make changes to the application
2. Commit and push to GitHub
3. CI/CD pipeline automatically:
   - Runs tests
   - Scans for vulnerabilities
   - Builds container image
   - Deploys to staging/production
4. ArgoCD syncs the deployment

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │────│ GitHub Actions  │────│      GKE        │
│                 │    │    CI/CD        │    │   Cluster       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                               ┌─────────────────┐
                                               │     ArgoCD      │
                                               │   GitOps        │
                                               └─────────────────┘
```

## Monitoring

- Health checks on `/health`
- Prometheus metrics (ready for scraping)
- Structured logging
- Resource monitoring in Kubernetes

## Security

- 🔒 Helmet.js security headers
- 🚫 Non-root container execution
- 🔍 Vulnerability scanning in CI/CD
- 🏰 Kubernetes security contexts
- 🔐 Secret management with Kubernetes Secrets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
# Ready for deployment! 🚀
# Container registry ready! 📦
