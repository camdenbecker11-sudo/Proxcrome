# Proxcrome

Proxcrome runs a full Google Chrome browser inside a container and exposes it through noVNC over a browser-friendly web session. The browser is password-protected via x11vnc, and the remote access endpoint is served by noVNC/websockify.

This repository intentionally separates responsibilities:

- GitHub Pages hosts the landing/guide page
- Docker hosts the real browser session
- noVNC exposes the browser through the browser as a remote desktop

## What this does

- Starts Xvfb on a virtual display
- Starts fluxbox for a lightweight desktop
- Starts x11vnc with a password
- Starts websockify + noVNC on port 8080
- Launches Google Chrome in a persistent profile directory

## Quick start with Docker

```bash
docker-compose up --build
```

Then open:

```text
http://localhost:8080/vnc.html
```

Use the VNC password from:

- the `VNC_PASSWORD` environment variable if supplied
- or the generated password printed in the container logs

## Example with a custom launch URL

```bash
docker run -d --rm \
  -p 8080:8080 \
  -p 5900:5900 \
  -e VNC_PASSWORD=your-secure-password \
  -e TARGET_URL=https://www.xbox.com/play \
  --name proxcrome \
  camdenbecker11-sudo/proxcrome:latest
```

Open:

```text
http://localhost:8080/vnc.html
```

## Security notes

- Do not expose port 5900 publicly.
- Protect the noVNC endpoint with TLS and authentication if it is reachable from the internet.
- Use a strong VNC password.
- Prefer a reverse proxy in front of the noVNC service for production deployments.

## GitHub Pages guide site

This repo includes a static landing page in the root that can be published with GitHub Pages. That page is only a guide and cannot run Docker or noVNC itself; it points users to the deployed remote browser host.

## Why Pages is separate from the browser

GitHub Pages can only serve static files. It cannot run a desktop browser, VNC server, or a Dockerized Chrome session. The real Chrome session must run on a host that supports Docker or a VM.

## Recommended deployment model

- Host this repo on GitHub Pages for the public guide/instructions.
- Run the Docker container on a VPS, cloud VM, or your own host with HTTPS.
- Put a reverse proxy in front of the browser host.
- Expose only the noVNC web endpoint publicly (for example `https://browser.example.com/`).

## Example production layout

```text
GitHub Pages: https://camdenbecker11-sudo.github.io/Proxcrome/
Remote browser: https://browser.example.com/vnc.html
```

This gives you a browser-access guide page plus a private full desktop Chrome session behind a password.
