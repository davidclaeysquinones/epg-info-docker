# epg-info-docker

This repo builds and Docker image of [iptv-org/epg](https://github.com/iptv-org/epg).
The purpose is to make the deployment easier and more suitable for different environments.

The original repository of this image is hosted on https://git.claeyscloud.com/david/epg-info-docker.<br>
A public mirror is available at https://github.com/davidclaeysquinones/epg-info-docker.

## Dependencies
[Node](https://nodejs.org/en)<br>
[pm2](https://www.npmjs.com/package/pm2)<br>
[serve](https://www.npmjs.com/package/serve)<br>

The image is based on `node:22-alpine` in order to be more lightweight.
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
By default some fixes are available. These fixes have been validated before being added to this repo.
However this option is disabled by default since you might only want to run the unmodified source.
If you have suggestions or a problem with them please submit an issue.

This the list of the provided custom fixes :

| Provider           | Author(s)                                                        | Status                                                                                                                                                         |
|--------------------|------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| movistarplus.es    | [davidclaeysquinones](https://github.com/davidclaeysquinones)    | [PR](https://github.com/iptv-org/epg/pull/2440) pending approval                                                                                               |
| orangetv.orange.es | [fraudiay79](https://github.com/fraudiay79) and [davidclaeysquinones](https://github.com/davidclaeysquinones)   | [PR](https://github.com/iptv-org/epg/pull/2485) merged since commit [8a8262e](https://github.com/iptv-org/epg/commit/8a8262eacb46b2d35df7eb11f46de22263eab053)                                             |
| pickx.be           | [davidclaeysquinones](https://github.com/davidclaeysquinones) and [BellezaEmporium](https://github.com/BellezaEmporium)   | [PR](https://github.com/iptv-org/epg/pull/2525) merged since commit [fd91a9c](https://github.com/iptv-org/epg/commit/fd91a9c532b476f6e192a564371d30e766b762ab)                                    |
| telenet.tv         | [davidclaeysquinones](https://github.com/davidclaeysquinones)    | [PR](https://github.com/iptv-org/epg/pull/2429) merged since commit [fd382db](https://github.com/iptv-org/epg/commit/fd382db08da7a96150928b8dcfef115e29e661d3) |
| web.magentatv.de   | [klausellus-wallace](https://github.com/klausellus-wallace)      | [PR](https://github.com/iptv-org/epg/pull/2458) merged since commit [61afe09](https://github.com/iptv-org/epg/commit/61afe090b6e7892cc5426457d960e9452222f885)                                                                                               |

If for some reason you want to include your own provider fixes this is possible by creation a mapping in the `/fixes` folder.<br>
The expected structure is */fixes/`provider_name`/`provider_name`.config.js*.<br>
It is recommended that you take existing provider code as a base for your customisations.

### Environment Variables

| Variable                      | Description                                                                | Default                          |
|-------------------------------|----------------------------------------------------------------------------|----------------------------------|
| CRON_SCHEDULE                 | CRON expression describing the recurrence for epg retrieval.               | `0 0,12 * * *`                   |            
| DAYS                          | Describes the desired amount of days in the future for for epg retrieval.  | 14                               |
| MAX_CONNECTIONS               | The maximum amount of parallel connections that can be established         | 10                               |
| ENABLE_FIXES                  | Some fixes to providers take a long time to be merged into the main branch.<br>When this option is enabled some of these fixes will also be included.<br>The source code for these fixes can be seen under the `fixes` folder.<br> Recreate the container when changing this variable in order for it to take effect  | false            |
| API_URL                       | The endpoint where channel information will be grabbed                     | `https://iptv-org.github.io/api` |

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

Normally when a change is made in the source repository the documentation is updated and a new tag is created in this repository. This is completely normal since the source repository is only cloned during the build process of the docker image.

Sometimes a new version of this image will be bound to the same source commit. This will happen when improvements are made to the image.

- 1.0.0 &nbsp;
  [08-01-2024](https://github.com/iptv-org/epg/commit/793c74ca397504fc2afc8fbfa998e0b8e4ca45d9)
- 1.0.1 &nbsp;
  [08-14-2024](https://github.com/iptv-org/epg/commit/270e85cfae6f0f691c2e6ab7ce511d60fd687565)
- 1.0.2 &nbsp;
  [09-07-2024](https://github.com/iptv-org/epg/commit/4e3b06a86e225cdd1b9362a683e6770fb68ff28f)
- 1.0.3 &nbsp;
  [09-14-2024](https://github.com/iptv-org/epg/commit/c69f3c93b1123ddf0fecc62c7067fced59ae4e99)
- 1.0.4 &nbsp;
  [09-30-2024](https://github.com/iptv-org/epg/commit/d90c7a54b941238cb92391b33d80a75e746d3002)
- 1.0.5 &nbsp;
  [10-02-2024](https://github.com/iptv-org/epg/commit/713dbf60a1cb9623ffcab6ab370ee9a78b32102b)
- 1.0.6 &nbsp;
  [10-02-2024](https://github.com/iptv-org/epg/commit/713dbf60a1cb9623ffcab6ab370ee9a78b32102b)<br>Adds possibility to enable custom fixes
- 1.0.7 &nbsp;
  [10-02-2024](https://github.com/iptv-org/epg/commit/713dbf60a1cb9623ffcab6ab370ee9a78b32102b)<br>Adds improvement to the docker image size
- 1.0.8 &nbsp;
  [10-10-2024](https://github.com/iptv-org/epg/commit/2241bc261fd37b8b16e036a0b61167030a5ce2e6)
- 1.0.9 &nbsp;
  [10-12-2024](https://github.com/iptv-org/epg/commit/fd382db08da7a96150928b8dcfef115e29e661d3)
- 1.0.10
  [10-14-2024 12:50](https://github.com/iptv-org/epg/commit/a3e7661f95103cbee4bcb78bd483396680e9abfc)
- 1.0.11 
  [10-14-2024 17:34](https://github.com/iptv-org/epg/commit/7610f7b9f5cc1ccab8d17f3408a95d31b36ace7c)
- 1.0.12
  [10-14-2024](https://github.com/iptv-org/epg/commit/7610f7b9f5cc1ccab8d17f3408a95d31b36ace7c)<br>Fix Pickx.be url
- 1.0.13
  [10-14-2024](https://github.com/iptv-org/epg/commit/7610f7b9f5cc1ccab8d17f3408a95d31b36ace7c)<br>Add custom fix for web.magentatv.de
- 1.0.14
  [10-14-2024](https://github.com/iptv-org/epg/commit/7610f7b9f5cc1ccab8d17f3408a95d31b36ace7c)<br>Change fix for movistarplus.es in order to work with new API
- 1.0.15
  [11-26-2024](https://github.com/iptv-org/epg/commit/d15911006e163262c0c7f267deae28160c0d7a8f)<br>Add option to customize channel endpoint
- 1.0.16
  [11-26-2024](https://github.com/iptv-org/epg/commit/d15911006e163262c0c7f267deae28160c0d7a8f)<br>Fix icons for movistarplus.es
- 1.0.17
  [11-26-2024](https://github.com/iptv-org/epg/commit/d15911006e163262c0c7f267deae28160c0d7a8f)<br>Update fix for pickx.be
- 1.0.18
  [11-27-2024 01:51](https://github.com/iptv-org/epg/commit/78dad4cfb4fc16f078c3b44b5534779c7c645b6b)
- 1.0.19
  [11-27-2024 15:43](https://github.com/iptv-org/epg/commit/e5f0850b3b2e35ed394f00ac68b699eaabc4f0e4)
- 1.0.20
  [11-28-2024](https://github.com/iptv-org/epg/commit/da18b70ddb1c3950e5a315411fd9aeaf60b6092c)
- 1.0.21
  [11-28-2024](https://github.com/iptv-org/epg/commit/da18b70ddb1c3950e5a315411fd9aeaf60b6092c)<br>Add orangetv.es
- 1.0.22
  [11-30-2024](https://github.com/iptv-org/epg/commit/1883338c0aee9909ac4567312b25701d10a765f2)
- 1.0.23
  [12-02-2024](https://github.com/iptv-org/epg/commit/296d6162ecbeb1b3c3e392845187d30624d50aa2)
- 1.0.24
  [12-02-2024](https://github.com/iptv-org/epg/commit/296d6162ecbeb1b3c3e392845187d30624d50aa2)<br>Fix for movistarplus.es channel grabber
- 1.0.25
  [12-04-2024](https://github.com/iptv-org/epg/commit/864e0ac2c4761d926b203a85a382a4bdc87fbc17)
- 1.0.26
  [12-05-2024](https://github.com/iptv-org/epg/commit/581441834af6f089c3930ad2d7ff1de2c701a6d9)
- 1.0.27
  [12-07-2024](https://github.com/iptv-org/epg/commit/ce4f3e69358385d1fb8e79df8129c63d6314a802)
- 1.0.28
  [12-08-2024](https://github.com/iptv-org/epg/commit/f9c8fc1b2dd63465564aba0c720096574980c58f)
- 1.0.29
  [12-11-2024](https://github.com/iptv-org/epg/commit/581f5e0ca94bd6d05c33f53951df078d702b2510)
- 1.0.30
  [12-16-2024](https://github.com/iptv-org/epg/commit/b9bbd32d354315eb292e3b82da09785e575a9781)
- 1.0.31
  [12-17-2024](https://github.com/iptv-org/epg/commit/7237a62d94c5691f7f467b334f846efce93b08ff)<br>Fix for Pickx.be + mayor program updates
- 1.0.32
  [12-20-2024](https://github.com/iptv-org/epg/commit/f00d53cb7be3cd7f6625897709cab005fe1b3dc4)
- 1.0.33
  [12-21-2024](https://github.com/iptv-org/epg/commit/c108aa586e25d2e8914baeca6c05cc6755718665)
- 1.0.34
  [12-27-2024](https://github.com/iptv-org/epg/commit/141fc210c4b7109e8ba09299d4f49c451ae0db4e)
- 1.0.35
  [12-31-2024 06:25](https://github.com/iptv-org/epg/commit/7e7efaa48717d6b96f6d05aa9cf73271750d788b)
- 1.0.36
  [12-31-2024 17:32](https://github.com/iptv-org/epg/commit/5ffe285c1e5882e905c5aaee672849f6f89e5cf3)
- 1.0.37
  [09-01-2025](https://github.com/iptv-org/epg/commit/8e39af2a4d7c15f442a3e686144278e97151d46e)
- 1.0.38
  [13-01-2025](https://github.com/iptv-org/epg/commit/9a565f16f4016e49d17b762477e0f6d29bb0f970)
- 1.0.39
  [14-01-2025](https://github.com/iptv-org/epg/commit/76df1541d8b0b90533ea74dcbb7815c27425b608)
- 1.0.40
  [14-01-2025](https://github.com/iptv-org/epg/commit/76df1541d8b0b90533ea74dcbb7815c27425b608)<br> Fixes issue with api url
- 1.0.41
  [15-01-2025](https://github.com/iptv-org/epg/commit/65331dff1c6728c3012e314e51d40da85d2d7f3c)
- 1.0.42
  [15-01-2025](https://github.com/iptv-org/epg/commit/5958c77c65a652285da64ad8a77d137306ca46d7)
- 1.0.43
  [20-01-2025](https://github.com/iptv-org/epg/commit/7b2cfba7f5d4df8c01ff74a7c26d7695cb750244)
- 1.0.44
  [21-01-2025](https://github.com/iptv-org/epg/commit/b69d61af5e46cea4f7dcb15a00d897397c23defa)
- 1.0.45
  [23-01-2025](https://github.com/iptv-org/epg/commit/bc4b7fcfd51325cc597ccce13821f355dd0fbc72)
- 1.0.46
  [27-01-2025](https://github.com/iptv-org/epg/commit/a45a346ec83cae3863b8d0e1cbe7abd99d6fef36)
- 1.0.47
  [29-01-2025](https://github.com/iptv-org/epg/commit/106ae083d243df825958dcf4fea1d48d2765cf72)
- 1.0.48
  [30-01-2025](https://github.com/iptv-org/epg/commit/e57dfaff41f498ffbfe79ecadd37f7f254dad0cc)
- 1.0.49
  [02-02-2025](https://github.com/iptv-org/epg/commit/6b45cd9bd60058fdb7b974ad610c2d6565317f3b)
- 1.0.50
  [05-02-2025](https://github.com/iptv-org/epg/commit/7f6849869f7182ddfa1a01b08a160ff8d2129441)