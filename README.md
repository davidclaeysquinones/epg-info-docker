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

#### Channels file
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

#### Custom fixes

Through the `ENABLE_FIXES` variable custom provider fixes can be applied to the container.
By default some fixes are available. If you have suggestions or a problem with them please submit an issue.
If for some reason you want to include your own provider fixes this is possible by creation a mapping in the `/fixes` folder.<br>
The expected structure is */fixes/`provider_name`/`provider_name`.config.js*.<br>
It is recommended that you take existing provider code as a base for your customisations.

### Environment Variables

| Variable                      | Description                                                                | Default          |
|-------------------------------|----------------------------------------------------------------------------|------------------|
| CRON_SCHEDULE                 | CRON expression describing the recurrence for epg retrieval.               | `0 0,12 * * *`   |            
| DAYS                          | Describes the desired amount of days in the future for for epg retrieval.  | 14               |
| MAX_CONNECTIONS               | The maximum amount of parallel connections that can be established         | 10               |
| ENABLE_FIXES                  | Some fixes to providers take a long time to be merged into the main branch.<br>When this option is enabled some of these fixes will also be included.<br>The source code for these fixes can be seen under the `fixes` folder.<br> Recreate the container when changing this variable in order for it to take effect  | false            |

### Compose file

```sh
version: '3.3'
services:
  epg:
    image: git.claeyscloud.com/david/epg-info:latest
    #image: ghcr.io/davidclaeysquinones/epg-info:latest
    #image: davidquinonescl/epg-info:latest
    volumes:
      # add a mapping in order to add the channels file
      - /docker/epg:/config
    ports:
      - 6080:3000
    environment:
      # specify the time zone for the server
      - TZ=Etc/UTC
      # uncomment the underlying line if you want to enable custom fixes
      #- ENABLE_FIXES=true
    restart: unless-stopped
```

### Versions

This image is bound to the content of the [iptv-org/epg](https://github.com/iptv-org/epg) repository. In the underlying list you can see to which commit each version of the docker image is bound. 

Normally when a change is made in the source repository the documention is updated and a new tag is created in this repository. This is completely normal since the source repository is only cloned during the build process of the docker image.

Sometimes a new version of this image will be bound to the same source commit. This will happen when improvements are made to the image.

- 1.0.0
  [08-01-2024](https://github.com/iptv-org/epg/commit/793c74ca397504fc2afc8fbfa998e0b8e4ca45d9)
- 1.0.1
  [08-14-2024](https://github.com/iptv-org/epg/commit/270e85cfae6f0f691c2e6ab7ce511d60fd687565)
- 1.0.2
  [09-07-2024](https://github.com/iptv-org/epg/commit/4e3b06a86e225cdd1b9362a683e6770fb68ff28f)
- 1.0.3
  [09-14-2024](https://github.com/iptv-org/epg/commit/c69f3c93b1123ddf0fecc62c7067fced59ae4e99)
- 1.0.4
  [09-30-2024](https://github.com/iptv-org/epg/commit/d90c7a54b941238cb92391b33d80a75e746d3002)
- 1.0.5
  [10-02-2024](https://github.com/iptv-org/epg/commit/713dbf60a1cb9623ffcab6ab370ee9a78b32102b)
- 1.0.6
  [10-02-2024](https://github.com/iptv-org/epg/commit/713dbf60a1cb9623ffcab6ab370ee9a78b32102b)<br>Adds possibility to enable custom fixes
- 1.0.7
  [10-02-2024](https://github.com/iptv-org/epg/commit/713dbf60a1cb9623ffcab6ab370ee9a78b32102b)<br>Adds improvement to the docker image size
- 1.0.8
  [10-10-2024](https://github.com/iptv-org/epg/commit/2241bc261fd37b8b16e036a0b61167030a5ce2e6)
- 1.0.9
  [10-12-2024](https://github.com/iptv-org/epg/commit/fd382db08da7a96150928b8dcfef115e29e661d3)
- 1.0.10
  [10-14-2024](https://github.com/iptv-org/epg/commit/a3e7661f95103cbee4bcb78bd483396680e9abfc)