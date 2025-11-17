# AGENTS.md

## Build/Lint/Test Commands
- **Build**: `make test-yaml` (validate YAML syntax)
- **Lint**: No linting configured
- **Test**: `make test` (YAML validation + dry-run deployment)
- **Run single test**: N/A (infrastructure testing only)

## Code Style Guidelines

### Kubernetes Manifests
- Use Helm-free YAML manifests in separate directories per service
- Follow linuxserver.io container image conventions
- Use consistent environment variables (TZ, PGID, PUID)
- Implement VPN sidecars for torrent services (Gluetun)

### Naming Conventions
- Services: lowercase with hyphens (jackett, plex, radarr)
- Deployments: `{service}-kube-{service}` or `{service}-vpn` pattern
- PVCs: descriptive names (public-share, media-storage)
- Secrets: `{service}-credentials` or `{provider}-credentials`

### Security
- Store VPN credentials in separate secret files
- Use ClusterIP services for internal access only
- Route torrent traffic through VPN sidecars
- Gitignore sensitive files (*.key, *secret*.yaml, *credentials*.yaml)

### Deployment Structure
- Shared resources in `shared/` directory (PVCs, ConfigMaps, Secrets)
- Individual service directories with deployment.yaml and service.yaml
- Use Makefile for automation (deploy, test, update, cleanup)
- Namespace: `media` for all resources

### Formatting
- 2-space indentation for YAML
- Consistent label selectors and metadata
- Resource limits and requests where appropriate
- Comments for complex configurations