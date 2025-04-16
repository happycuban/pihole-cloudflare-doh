## 📦 Pi-hole + Cloudflared (DoH) Stack

This stack runs [Pi-hole](https://pi-hole.net) as your local DNS sinkhole, with [Cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/dns/over-https/) as a local **DNS-over-HTTPS (DoH)** proxy to Cloudflare DNS — all in Docker, integrated with [Traefik](https://traefik.io) for reverse proxying.

---

### 🧙‍♂️ Services

#### 🔹 `cloudflared`

- Handles secure DNS-over-HTTPS resolution to upstream DNS (Cloudflare)
- Exposes a local DNS server on port `5053`
- Lightweight and isolated
- Uses static IP for predictable routing within Docker

#### 🔹 `pihole`

- Blocks ads and trackers at the DNS level
- Forwards DNS requests to `cloudflared` (`172.70.9.2#5053`)
- Exposes port `500` for web UI
- Connected to `proxy` network for reverse proxy via Traefik

---

### ⚙️ Configuration Overview

#### DNS Flow

```
Devices on LAN --> Pi-hole (172.70.9.3) --> Cloudflared (172.70.9.2) --> DoH --> Cloudflare
```

#### Network Setup

- `pihole_internal`: Internal communication between Pi-hole and Cloudflared
- `proxy`: External reverse proxy (Traefik)

---

### 🔐 Environment Variables

| Variable                     | Description                              |
|-----------------------------|------------------------------------------|
| `FTLCONF_webserver_api_password` | Password for Pi-hole UI/API              |
| `FTLCONF_dns_upstreams`     | Cloudflared IP and port for upstream DNS |
| `FTLCONF_dns_listeningMode` | Set to `all` to listen on all interfaces |
| `TZ`                        | Timezone for container logs and FTL      |

---

### 📁 Volumes

```yaml
volumes:
  - './data:/etc/pihole/'
```

> Optional: You can mount `./data/etc-dnsmasq.d/` as well if you want to manage `dnsmasq` configs manually.

---

### 🧪 Traefik Integration

This stack assumes you're using [Traefik](https://traefik.io) as your reverse proxy. It exposes Pi-hole's admin panel at:

```
http://pihole.home.local
```

Update your local DNS or `/etc/hosts` file to point `pihole.home.local` to your Docker host IP.

---

### 📣 How to Start

```bash
docker compose up -d
```

Access Pi-hole:

- Web UI: http://pihole.home.local (port `500` exposed to host)
- DNS: point your router or device to the Docker host IP

---

### ✅ Requirements

- Docker + Docker Compose
- Custom `tekmodedk/cloudflared:latest-arm` image built and pushed (or build locally)
- Reverse proxy (Traefik) network already created:
  ```bash
  docker network create proxy
  ```

---

### 🔐 Security Tips

- Change `FTLCONF_webserver_api_password` from default
- Restrict access to port `500` if not using Traefik
- Regularly update the `cloudflared` image for security patches

