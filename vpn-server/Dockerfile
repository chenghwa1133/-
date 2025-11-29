# Korean VPN Server - WireGuard based
FROM ubuntu:22.04

LABEL maintainer="Korean VPN Service"
LABEL description="WireGuard VPN Server for Korean connectivity"

# Install required packages
RUN apt-get update && apt-get install -y \
    wireguard \
    wireguard-tools \
    iptables \
    iproute2 \
    qrencode \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set timezone to Korea
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create config directory
RUN mkdir -p /etc/wireguard

# Expose WireGuard port
EXPOSE 51820/udp

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
