FROM alpine:latest

LABEL maintainer="Modesto Hernandez"
LABEL description="Standalone Cloudflared DoH proxy for Docker"
LABEL org.opencontainers.image.source="https://github.com/happycuban/pihole-cloudflare-doh"

# Install dependencies
RUN apk add --no-cache curl ca-certificates

# Download latest cloudflared binary for current arch
ARG TARGETARCH
RUN curl -L -o /usr/local/bin/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH}" && \
    chmod +x /usr/local/bin/cloudflared

# Add config
COPY config.yml /etc/cloudflared/config.yml

EXPOSE 5053/udp 5053/tcp

ENTRYPOINT ["cloudflared", "--config", "/etc/cloudflared/config.yml"]
