# epg-info-docker

This repo builds and Docker image of [iptv-org/epg](https://github.com/iptv-org/epg).
The purpose is to make the deployment easier and more suitable for different environments.


## Dependencies
[Node](https://nodejs.org/en)<br>
[pm2](https://www.npmjs.com/package/pm2)<br>
[serve](https://www.npmjs.com/package/serve)<br>

## Docker image

### Paths

An example `channels.xml` is included by default in the image.
However if you want to configure your own channels you need to provide your own configuration file.
You can do this by creating a mapping in the `/config` folder.

### Environment Variables

| Variable                      | Description                                                                | Default          |
|-------------------------------|----------------------------------------------------------------------------|------------------|
| CRON_SCHEDULE                 | CRON expression describing the recurrence for epg retrieval.               | `0 0,12 * * *`   |            
| DAYS                          | Describes the desired amount of days in the future for for epg retrieval.  | 14               |
| MAX_CONNECTIONS               | The maximum amount of parallel connections that can be established         | 10               |

