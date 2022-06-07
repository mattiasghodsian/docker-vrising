<p align="center">
  <a href="https://github.com/mattiasghodsian/dockerized-vrising-server">
    <img alt="Dockerized V Rising dedicated server" src="assets/dockerized-vrising-dedicated-server.png?raw=true" height="250">
  </a>
  <p  align="center">Dockerized V Rising dedicated server</p>
</p>

<p align="center">
  <a href="https://hub.docker.com/r/rakma/dockerized-vrising-server">
    <img alt="Github stars" src="https://badgen.net/docker/stars/rakma/dockerized-vrising-server?icon=docker&label=stars" />
  </a>
  <a href="https://hub.docker.com/r/rakma/dockerized-vrising-server">
    <img alt="Github stars" src="https://badgen.net/docker/pulls/rakma/dockerized-vrising-server?icon=docker&label=pulls" />
  </a>
  <a href="https://github.com/mattiasghodsian/dockerized-vrising-server">
    <img alt="Github stars" src="https://badgen.net/github/stars/mattiasghodsian/dockerized-vrising-server?icon=github&label=stars" />
  </a>
  <a href="https://github.com/mattiasghodsian/dockerized-vrising-server">
    <img alt="Github forks" src="https://badgen.net/github/forks/mattiasghodsian/dockerized-vrising-server?icon=github&label=forks" />
  </a>
  <img alt="Github last-commit" src="https://img.shields.io/github/last-commit/mattiasghodsian/dockerized-vrising-server" />
</p>

## Overview
Dockerized V Rising dedicated server on Ubuntu 22.04 with Wine and extra features based on `TrueOsiris/docker-vrising`.
## Features
- Set a schedule to run backups automatically.
- Send a discord message on server up/down
## Usage
Save below as `docker-compose.yml` and run `docker-compose up -d` in the same directory.

```
version: '3.3'
services:
  vrising:
    image: rakma/dockerized-vrising-server
    container_name: vrising
    network_mode: bridge
    environment:
      - TZ=Europe/Stockholm
      - SERVERNAME=Dockerized VRising
      - AUTO_BACKUP=1
    volumes:
      - './server:/mnt/vrising/server:rw'
      - './data:/mnt/vrising/persistentdata:rw'
    ports:
      - '9876:9876/udp'
      - '9877:9877/udp'
    restart: unless-stopped
```

## Environment Variables
A set of environment variables have default values provided as part of the image. 

| Variable | Value | Required | Description |
| - | - | - | - |
| TZ | `Europe/Stockholm` | ✔️ | Sets machines timezone |
| SERVERNAME | `Dockerized VRising` | ❌ |  Sets the server name and also ignores what's been in `ServerHostSettings.json`  |
| WORLDNAME | `world1` | ❌ |  Default: `world1` |
| AUTO_BACKUP | `1` | ❌ | Enables auto backup task, backups older then 1 day will be removed <br>Default: `0` |
| AUTO_BACKUP_SCHEDULE | `0 */1 * * *` | ❌ |  Default: `0 */3 * * *` |
| DISCORD_WEBHOOK_URL | `webhooks-url` | ❌ | Send a discord message on server up/down |

*Edit `server/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json` for remaining options.*
## Ports
The server default ports are `9876` and `9876`, can be altered in `ServerHostSettings.json` (Don't forget to change exposed ports on your container). **Don't forget to port forward on your router.**

## Volumes

| Volume | Container path | Description |
| - | - | - |
| server | /mnt/vrising/server | Holds the server files |
| data | /mnt/vrising/persistentdata | Holds `world`, `backup` directories |

## RCON - Optional
To enable RCON edit `ServerHostSettings.json` and paste following lines after `QueryPort`. To communicate using RCON protocal use the [RCON CLI](https://github.com/gorcon/rcon-cli) by gorcon.

```json
"Rcon": {
  "Enabled": true,
  "Password": "docker",
  "Port": 25575
},
```

## FAQ

**Q:** How do i list my server ingame ? <br>
**A:** Set `"ListOnMasterServer"` to **true** in `server/VRisingServer_Data/StreamingAssets/Settings/ServerHostSettings.json`
