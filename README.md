# epg-info-docker

This repo builds and Docker image of [iptv-org/epg](https://github.com/iptv-org/epg).
The purpose is to make the deployment easier and more suitable for different environments.

The original repository of this image is hosted on https://git.claeyscloud.com/david/epg-info-docker.<br>
A public mirror is available at https://github.com/davidclaeysquinones/epg-info-docker.

## Dependencies
[Node](https://nodejs.org/en)<br>
[pm2](https://www.npmjs.com/package/pm2)<br>
[serve](https://www.npmjs.com/package/serve)<br>

The image is based on `node:21-alpine` in order to be more lightweight.
The `pm2` and `serve` packages are used in order to run the application in the container. 
## Docker image

### Paths

An example `channels.xml` is included by default in the image.<br>
```xml
<?xml version="1.0" encoding="UTF-8"?>
<channels>
  <channel site="movistarplus.es" lang="es" xmltv_id="24Horas.es" site_id="24H">24 Horas</channel>
  ...
</channels>
```
However if you want to configure your own channels you need to provide your own configuration file.<br>
You can do this by creating a mapping in the `/config` folder.

### Environment Variables

| Variable                      | Description                                                                | Default          |
|-------------------------------|----------------------------------------------------------------------------|------------------|
| CRON_SCHEDULE                 | CRON expression describing the recurrence for epg retrieval.               | `0 0,12 * * *`   |            
| DAYS                          | Describes the desired amount of days in the future for for epg retrieval.  | 14               |
| MAX_CONNECTIONS               | The maximum amount of parallel connections that can be established         | 10               |

### Compose file

```sh
version: '3.3'
services:
  epg:
    image: git.claeyscloud.com/david/epg-info:latest
    #image: image: git.claeyscloud.com/david/epg-info:latest:latest
    volumes:
      # add a mapping in order to add the channels file
      - /docker/epg:/config
    ports:
      - 6080:3000
    environment:
      # specify the time zone for the server
      - TZ=Etc/UTC
    restart: unless-stopped
```

### Versions

- 1.0.0
  [08-01-2024](https://github.com/iptv-org/epg/commit/793c74ca397504fc2afc8fbfa998e0b8e4ca45d9)
- 1.0.1
  [08-14-2024](https://github.com/iptv-org/epg/commit/270e85cfae6f0f691c2e6ab7ce511d60fd687565)
- 1.0.2
  [09-07-2024](https://github.com/iptv-org/epg/commit/4e3b06a86e225cdd1b9362a683e6770fb68ff28f)