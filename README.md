# DEPLOY HUGO SITE

## Docker Compose to deploy any simple hugo site with hugomods/hugo:nginx

## Deploy Instructions

These instructions assume a few things:
    - An already running and functional install of [Traefik](https://docs.traefik.io/)
      - See my [blog post](https://beardedtek.org/traefik-tailscale-linode-dns/) about setting up traefik.
    - Knowledge of docker and docker-compose
    - This will be running on Linux.  Adustments to Windows/Mac deployments may vary and are something that will not be covered, nor supported here.

### Create .env file

```bash
HUGO_VERSION=0.145.0
HUGO_REPO=https://github.com/johndoe/site.example.com
HUGO_OPTS="--minify --enableGitInfo"
DOMAIN=site.example.com
PROTOCOL=https
HUGO_SITENAME=site-example-com
DOCKER_USER=beardedtek
PULL_POLICY=build
NO_CACHE=true
```

- HUGO_VERSION: Hugo Version (leave blank to use latest)
- HUGO_REPO: Git Repository of Hugo Static Site
- HUGO_OPTS: Custom options for the hugo command
- DOMAIN: domain your site will be using
- PROTOCOL: either http or https
- HUGO_SITENAME: This is used to generate traefik labels and label the container name
- DOCKER_USER: This helps generate the image tag so that it's sanely named
  - ${DOCKER_USER}/${HUGO_SITENAME}:hugo-nginx
- PULL_POLICY: Set this to 'build' so that each time you bring the project up it builds the container
- NO_CACHE: Set this to true so that it actually pulls the repo down and builds it each time

## Adjust docker-compose as needed

You may specifically need to adjust your traefik labels depending on your setup.

```yaml
networks:
  traefik:
    external: true

services:
  hugo_nginx:
    build:
      context: .
      args:
        HUGO_VERSION: ${HUGO_VERSION}
        HUGO_REPO: ${HUGO_REPO}
        HUGO_OPTS: ${HUGO_OPTS}
        DOMAIN: ${DOMAIN}
        HUGO_SITENAME: ${HUGO_SITENAME}
        TRAEFIK_NETWORK: ${TRAEFIK_NETWORK}
    image: ${DOCKER_USER}/${HUGO_SITENAME}:hugo-nginx
    restart: unless-stopped
    networks:
      traefik:
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"
      - "traefik.http.routers.${HUGO_SITENAME:-hugo-nginx}.rule=Host(`${DOMAIN:-localhost}`)"
      - "traefik.http.routers.${HUGO_SITENAME:-hugo-nginx}.entryPoints=https"
      - "traefik.http.routers.${HUGO_SITENAME:-hugo-nginx}.tls=true"
      - "traefik.http.routers.${HUGO_SITENAME:-hugo-nginx}.tls.certresolver=le"
      - "traefik.http.routers.${HUGO_SITENAME:-hugo-nginx}.service=${HUGO_SITENAME:-hugo-nginx}-entrypoint"
      - "traefik.http.services.${HUGO_SITENAME:-hugo-nginx}-entrypoint.loadbalancer.server.port=80"
```

## Deploy

`docker-compose up -d`

## View Logs

`docker-compose logs -f`

## Shut down

`docker compose down`

## Restart

`docker compose restart`
