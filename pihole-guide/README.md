# Multi-Distro Pi-hole Automated Installer 

An automated Bash script designed to deploy a persistent Dockerized Pi-hole instance across multiple Linux distributions. It handles dependency checks, Docker installation, dynamic port conflicts, and security contexts out of the box.

## Features

- **Cross-Distribution Support**: Automatically detects package managers for **Arch Linux (pacman)**, **RHEL/Fedora (dnf)**, and **Debian/Ubuntu (apt)**.
- **Automated Docker Setup**: Installs Docker and the modern `docker-compose-plugin` if missing, ensures services are enabled, and automatically configures user group permissions without requiring a shell logout.
- **Port 53 Conflict Resolution**: Automatically detects if `systemd-resolved` (common in Ubuntu/Debian) is binding port 53, disables the DNS stub listener, and reconfigures the host's resolution to prevent Docker binding crashes.
- **Security-Aware**: Creates required configuration directories in `/etc/` and handles SELinux context labeling (`chcon`) for RHEL-based systems.
- **Fail-Safe Monitoring**: Implements strict exit-code handling on deployment failure to ensure predictable automation behavior.

## Repository Structure

```text
.
├── docker-compose.yml     # Pi-hole container configuration
├── install.sh             # Main deployment script
└── README.md              # Project documentation
```

## Usage

1. Clone this repository to your target machine:
   ```bash
   git clone https://github.com/va1k0inen/path-to-fisi
   cd path-to-fisi/pihole-guide
   ```

2. Make the script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the script (without `sudo`, the script internally handles privilege escalation and group application):
   ```bash
   ./install.sh
   ```

## Configuration Details

The script binds the container to persistent directories on the host system to ensure configuration and blocklists persist across updates:
- `/etc/pihole-docker/` -> `/etc/pihole/`
- `/etc/dnsmasq.d-docker/` -> `/etc/dnsmasq.d/`

*Note: Ensure your `docker-compose.yml` matches these paths before running the setup.*

## System Requirements

- OS: Arch Linux, Manjaro, Debian, Ubuntu, Linux Mint, Pop!_OS, or Fedora.
- Privileges: `sudo` access required for system package installations and port management.
