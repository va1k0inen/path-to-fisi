#!/bin/bash

# последний босс вайбкодинга лол
echo "Started an automized installation script"

if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
    echo "Docker or Docker Compose is missing. Starting installation"

    if command -v pacman &> /dev/null; then
        echo "Arch-based detected"
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm docker docker-compose

    elif command -v dnf &> /dev/null; then
        echo "RHEL-based detected"
        sudo dnf install -y docker docker-compose-plugin

    elif command -v apt-get &> /dev/null; then
        echo "Debian-based detected"
        sudo apt-get update
        sudo apt-get install -y docker.io docker-compose-plugin
    else 
        echo "Invalid packet manager detected"
        exit 1
    fi 

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER 
    echo "Docker and Docker Compose have been installed succesfully!"
else    
    echo "Docker and Docker Compose are already installed. Skipping..."
fi

if [ "$(id -gn)" != "docker" ]; then 
    exec sg docker "$0" "$@"
fi

echo "Proceeding to Pi-hole setup..."

sudo mkdir -p /etc/pihole-docker /etc/dnsmasq.d-docker

sudo chmod -R 775 /etc/pihole-docker /etc/dnsmasq.d-docker

echo "Checking port 53 availability..."

if ss -tulnp | grep -q ':53'; then 
    echo "Port 53 is already in use, tryin' to fix"

    if systemctl is-active --quiet systemd-resolved; then
        echo "Detected systemd-resolved conflict, disabling DNS stub."
        
        sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
        sudo sed -i 's/DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf

        sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
        # шатырым тайып кетты колмен барын жазуга шшс
        sudo systemctl restart systemd-resolved
    fi

    if ss -tulnp | grep -q ':53'; then
        echo "Port 53 still in use. Bailing out, you are on your own. Good luck."
        exit 1
    else 
        echo "Port 53 succesfully freed up"
    fi
else 
    echo "Port 53 is free, continue..."
fi
 
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd $SCRIPT_DIR

echo "Starting Pi-hole container"
docker compose up -d || { echo "Docker Compose failed!"; exit 1;}

echo "Docker Compose is all set! The name of container is $(sudo docker ps --filter "publish=53" --format '{{.Names}}')"
echo "Recommended to change Pi-hole web-interface's password by command: sudo docker exec -it name_of_your_container pihole setpassword"
exit 0