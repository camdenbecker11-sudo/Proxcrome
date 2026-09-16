# Proxcrome

Proxcrome runs a full Google Chrome browser inside a container and exposes it through noVNC over a browser-friendly web session. The browser is protected with a VNC password, and the web endpoint is meant to sit behind HTTPS.

This repository intentionally separates responsibilities:

- GitHub Pages hosts the public guide page
- Docker hosts the real browser session
- Caddy or another TLS reverse proxy protects the noVNC endpoint

## Production-ready deployment

1. Copy the environment file:

```bash
cp .env.example .env
```

2. Edit `.env` and set:

```env
TARGET_URL=https://www.xbox.com/play
VNC_PASSWORD=your-very-strong-password
DOMAIN=browser.example.com
EMAIL=you@example.com
```

3. Start the stack:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

4. Open the browser:

```text
https://browser.example.com/vnc.html
```

5. Enter the VNC password.

## Local dev run

```bash
docker compose up --build
```

Then open:

```text
http://localhost:8080/vnc.html
```

## Default behavior

The browser starts at:

```text
https://www.xbox.com/play
```

You can override it in `.env` with another URL if needed.

## Security notes

- Do not expose port 5900 publicly.
- Always put noVNC behind HTTPS.
- Use a strong VNC password.
- Do not run the browser directly on GitHub Pages; Pages cannot host the Chrome desktop session itself.

## GitHub Pages guide

The static site in the repo can be published from GitHub Pages. That page is only a guide and points users to the real remote browser host.

## Port map in production

- 80 → Caddy HTTP redirect
- 443 → Caddy HTTPS -> noVNC
- 8080 → internal only between Caddy and the browser container
- 5900 → internal only between noVNC and x11vnc
