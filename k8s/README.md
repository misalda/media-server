# Media Server Kubernetes Deployment

This directory contains clean, Helm-free Kubernetes manifests for deploying a complete media server stack.

## 🏗️ Architecture

- **Plex**: Media streaming server (port 32400)
- **Radarr**: Movie management and download automation (port 80)
- **Sonarr**: TV show management and download automation (port 80)
- **Transmission**: Torrent client with OpenVPN (port 80)
- **Jackett**: Torrent indexer proxy (port 80)

All services share a 500Gi persistent volume for media storage.

## 📁 Directory Structure

```
k8s/
├── jackett/         # Jackett indexer proxy
│   ├── deployment.yaml
│   └── service.yaml
├── plex/            # Plex media server
│   ├── deployment.yaml
│   └── service.yaml
├── radarr/          # Movie management
│   ├── deployment.yaml
│   └── service.yaml
├── sonarr/          # TV show management
│   ├── deployment.yaml
│   └── service.yaml
├── transmission/    # Torrent client
│   ├── deployment.yaml
│   └── service.yaml
├── shared/          # Shared resources
│   ├── pvc.yaml
│   ├── configmap.yaml
│   ├── openvpn.yaml
│   └── pia-credentials.yaml
├── Makefile         # Deployment automation
├── deploy.sh        # Legacy deployment script
├── README.md        # This file
└── .gitignore       # Security exclusions
```

## 🚀 Deployment

### Quick Deploy (Recommended)
```bash
cd k8s
make deploy        # Deploy all services with validation
# OR
make deploy-all    # Same as above
```

### Individual Service Deployment
```bash
make deploy-jackett     # Deploy only Jackett
make deploy-plex        # Deploy only Plex
make deploy-radarr      # Deploy only Radarr
make deploy-sonarr      # Deploy only Sonarr
make deploy-transmission # Deploy only Transmission
```

### Manual Deploy (Alternative)
```bash
export KUBECONFIG=/path/to/kubeconfig.yaml

# Apply shared resources first
kubectl apply -f shared/

# Apply applications (can be done individually or all at once)
kubectl apply -f jackett/ plex/ radarr/ sonarr/ transmission/
```

### Makefile Targets Overview
```bash
make help              # Show all available targets
make help-deploy       # Show deployment targets
make help-monitor      # Show monitoring targets
make help-maintain     # Show maintenance targets

make status            # Show status of all services
make logs              # Show logs for all services
make test              # Run validation tests

make update            # Update all services
make restart           # Restart all deployments
make cleanup           # Remove all services
```

## 🔧 Customization

### Update Container Images
Edit the `image:` field in deployment YAMLs:
```yaml
containers:
- image: linuxserver/plex:amd64-latest  # Change version here
```

### Modify Environment Variables
Add or edit environment variables in the `env:` section of deployments.

### Change Resource Limits
Update CPU/memory requests/limits in the `resources:` section.

## 📊 Monitoring

### Quick Status Check
```bash
make status          # Show status of all deployments, pods, and services
```

### View Logs
```bash
make logs            # Show logs for all services
make logs-jackett    # Show Jackett logs
make logs-plex       # Show Plex logs
make logs-transmission # Show Transmission logs
make logs-vpn        # Show VPN sidecar logs
```

### Manual Monitoring
```bash
kubectl get pods -n media
kubectl get services -n media
kubectl logs -f deployment/plex -n media
```

## 🔄 Updates

### Update Services
```bash
make update           # Update all services
make update-jackett   # Update only Jackett
make update-plex      # Update only Plex
make update-transmission # Update only Transmission
```

### Restart Services
```bash
make restart          # Restart all deployments
make restart-jackett  # Restart only Jackett
make restart-plex     # Restart only Plex
```

### Manual Updates
To update an application:
1. Edit the corresponding YAML file
2. Apply the changes: `kubectl apply -f deployments/plex.yaml`
3. Monitor the rollout: `kubectl rollout status deployment/plex -n media`

## 🛡️ Security & VPN Configuration

### Security Notes
- **VPN Sidecars**: Jackett and Transmission now use Gluetun VPN sidecars for secure traffic routing
- The OpenVPN secret contains VPN credentials - keep it secure
- The PIA credentials secret contains Private Internet Access VPN credentials
- Consider using sealed secrets or external secret management for production
- All services are currently ClusterIP (internal access only)

### VPN Sidecar Setup

**✅ COMPLETED**: VPN sidecar containers have been added to both Jackett and Transmission deployments.

#### Prerequisites
**⚠️ IMPORTANT:** Before deploying, update the PIA credentials in `k8s/shared/pia-credentials.yaml`:
- `OPENVPN_USER`: Your PIA username (base64 encoded)
- `OPENVPN_PASSWORD`: Your PIA password (base64 encoded)

To encode credentials:
```bash
echo -n "your_username" | base64
echo -n "your_password" | base64
```

#### Current Architecture
```
Pod
├── vpn-sidecar (qdm12/gluetun)
│   ├── NET_ADMIN capability
│   ├── PIA OpenVPN connection
│   └── Routes all pod traffic
└── main-app (jackett/transmission)
    └── Traffic routed through sidecar
```

#### Configuration Details
- **Provider**: Private Internet Access
- **Server Region**: AU Sydney (configurable in deployment YAML)
- **Credentials**: Stored in `pia-credentials` secret
- **Local Access**: 192.168.6.0/24 network allowed for local connections

#### Troubleshooting VPN
```bash
# Check VPN sidecar logs
kubectl logs -f deployment/jackett-vpn -n media -c vpn-sidecar
kubectl logs -f deployment/transmission-vpn -n media -c vpn-sidecar

# Test external IP (should show VPN IP)
kubectl exec -it deployment/jackett-vpn -n media -c jackett-vpn -- curl -s https://ipinfo.io/ip
kubectl exec -it deployment/transmission-vpn -n media -c transmission-vpn -- curl -s https://ipinfo.io/ip
```

#### Rollback Plan
If VPN issues occur:
1. Remove the VPN sidecar container from deployments
2. Restore original VPN configuration in main containers
3. Redeploy without the sidecar

**Resources**: [Gluetun Documentation](https://github.com/qdm12/gluetun) • [PIA Server List](https://www.privateinternetaccess.com/helpdesk/kb/articles/pia-servers)

## 📝 Recent Changes

### Transmission Deployment Updates
- **Image**: Changed from `haugene/transmission-openvpn:5` to `lscr.io/linuxserver/transmission:latest`
- **Environment Variables**: Updated to match linuxserver/transmission documentation
  - Removed: `LOCAL_NETWORK`, `TRANSMISSION_DOWNLOAD_DIR`, `DEBUG`
  - Changed: `TRANSMISSION_PEER_PORT` → `PEERPORT`, `TRANSMISSION_WEB_UI` → `TRANSMISSION_WEB_HOME`
  - Added: `TZ=Etc/UTC`
- **Volume Mounts**: Updated to match linuxserver standards
  - `/data` → `/config` for configuration
  - Added `/watch` mount for torrent watch folder

### Jackett Deployment Updates
- **Image**: Changed from `misalda/jackettvpn:latest` to `lscr.io/linuxserver/jackett:latest`
- **Environment Variables**: Updated to match linuxserver/jackett documentation
  - Removed: `BIND_ADDRESS`, `LAN_NETWORK`, `DEBUG`
  - Added: `TZ=Etc/UTC`
  - Updated: `PGID` from `65534` to `1000`
- **Volume Mounts**: Updated to match linuxserver standards
  - `/blackhole` → `/downloads` for torrent blackhole directory

## 🧹 Cleanup

### Remove Everything
```bash
make cleanup         # Remove all services and shared resources
# OR
kubectl delete namespace media  # Nuclear option
```

### Remove Specific Applications
```bash
make clean-app APP=transmission  # Remove only Transmission
make clean-app APP=radarr        # Remove only Radarr
```

### Manual Cleanup
```bash
kubectl delete -f transmission/  # Remove only Transmission
kubectl delete -f radarr/ sonarr/  # Remove multiple apps
kubectl delete -f shared/         # Remove shared resources (⚠️ affects all apps)
```