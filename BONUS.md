## ✨ Bonus: All-in-One Container (Pi-hole + Cloudflared)

If you prefer to run **Pi-hole and Cloudflared in a single container**, this method provides a compact solution. However, due to recent upstream changes in the Pi-hole Docker image, **this approach only works with version `2024.07.0` or earlier** (Debian-based). The latest versions of Pi-hole use Alpine and no longer support `s6-overlay` the same way.

---

### 🧹 Compose Example

```yaml
services:
  pihole-dot-doh:
    container_name: pihole-doh
    image: tekmodedk/pihole-doh:2024.07.0-arm
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "500:80/tcp"
    environment:
      TZ: 'Europe/Copenhagen'
      FTLCONF_webserver_api_password: 'password123'
      FTLCONF_dns_upstreams: '127.0.0.1#5053'
      FTLCONF_dns_listeningMode: 'all'
    volumes:
      - './data:/etc/pihole/'
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
```

---

### 🔧 Dockerfile (Optional Build)

> 🙏 Based on and inspired by: [eltonk/pihole-doh](https://github.com/eltonk/pihole-doh.git)


> ⚠️ **You only need this if you want to build the image yourself.**  
> Otherwise, just use the prebuilt image: `tekmodedk/pihole-doh:2024.07.0-arm`

```dockerfile
FROM pihole/pihole:2024.07.0

LABEL maintainer="Modesto Hernandez"
LABEL url="https://github.com/happycuban/pihole-cloudflare-doh"

# Install and configure cloudflared
RUN /bin/bash -c 'cd /tmp; \
apt-get update; \
apt-get install wget -y; \
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm; \
mv ./cloudflared-linux-arm /usr/local/bin/cloudflared; \
chmod +x /usr/local/bin/cloudflared;'

COPY config.yml /etc/cloudflared/config.yml

RUN /bin/bash -c 'mkdir -p /etc/services.d/cloudflared; \
echo "#!/usr/bin/env bash" > /etc/services.d/cloudflared/run; \
echo "s6-echo Starting cloudflared" >> /etc/services.d/cloudflared/run; \
echo "exec /usr/local/bin/cloudflared --config /etc/cloudflared/config.yml" >> /etc/services.d/cloudflared/run; \
echo "#!/usr/bin/env bash" > /etc/services.d/cloudflared/finish; \
echo "s6-echo Stopping cloudflared" >> /etc/services.d/cloudflared/finish; \
echo "killall -9 cloudflared" >> /etc/services.d/cloudflared/finish;'

RUN chmod +x /etc/services.d/cloudflared/run; \
chmod +x /etc/services.d/cloudflared/finish;
```

---

### ⚠️ Limitations

- This image must be **built from the provided Dockerfile** if not using the published one
- You cannot upgrade Pi-hole to a version newer than `2024.07.0` without breaking `s6`-based service management
- This setup is **not modular** (i.e., cloudflared is baked in)

---

### ✅ Use This If:

- You want a **single container** solution
- You're okay pinning Pi-hole to a known working version
- You want to keep setup simple (one `docker run` or `compose` service)

---

