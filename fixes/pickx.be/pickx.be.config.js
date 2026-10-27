const axios = require('axios')
const dayjs = require('dayjs')
const utc = require('dayjs/plugin/utc')
const timezone = require('dayjs/plugin/timezone')

dayjs.extend(utc)
dayjs.extend(timezone)

const API_ENDPOINT = 'https://api.prod-ntvbe.tvapi-web.pickx.be'
const API_IMAGE_ENDPOINT =
  'https://experience-cache.cdi.streaming.proximustv.be/posterserver/poster/EPG'

const TIMEZONE = 'Europe/Brussels'

// every tray of the AVS backend is addressed through
// /{tenant}/{version}/{cluster}/{locale}/{platform}/{property}, where the cluster is the access
// level ("A" is anonymous, which is enough for the public guide) and the platform has to be WEB
const BASE_PATH = '/AGL/1.5/A/{locale}/WEB/PXS'

// the locale only selects the language of the labels the API itself emits, never the language of
// the guide, so a channel keeps its broadcast language whichever locale is requested
const LOCALES = { en: 'ENG', fr: 'FRA', nl: 'NLD', de: 'DEU' }

const LANGUAGES = {
  ara: 'ar',
  deu: 'de',
  eng: 'en',
  fra: 'fr',
  ita: 'it',
  nld: 'nl',
  spa: 'es'
}

// the channel tray refuses any page wider than this
const CHANNELS_PER_PAGE = 100

module.exports = {
  site: 'pickx.be',
  days: 2,
  request: {
    headers: {
      Origin: 'https://tv.pickx.be',
      Referer: 'https://tv.pickx.be/'
    }
  },
  url({ channel, date }) {
    // the guide is cut into Brussels days, while the grabber hands us a UTC moment. Both edges
    // are resolved from their own calendar date, because adding a day to the start would add a
    // flat 24 hours and so cut the 25 hour day short, or overrun the 23 hour one, when the
    // Brussels clock shifts
    const start = brusselsMidnight(date)
    const stop = brusselsMidnight(date.add(1, 'd'))

    // from/to paginates the channels of the tray, not their programs, so asking for a single
    // channel still returns its whole day
    return `${API_ENDPOINT}${basePath(channel.lang)}/TRAY/EPG?from=1&to=1&filter_channelIds=${
      channel.site_id
    }&filter_startTime=${start.valueOf()}&filter_endTime=${stop.valueOf()}`
  },
  parser({ content }) {
    const programs = []
    parseItems(content).forEach(item => {
      const data = item.metadata
      if (!data) return

      programs.push({
        title: data.title,
        sub_title: data.episodeTitle,
        description: data.longDescription || data.shortDescription,
        category: data.genres,
        image: parseImage(data),
        season: data.season,
        episode: data.episodeNumber,
        actors: data.actors,
        director: data.directors,
        date: data.year,
        country: data.country,
        start: dayjs(data.airingStartTime),
        stop: dayjs(data.airingEndTime)
      })
    })

    return programs
  },
  async channels() {
    const channels = []

    for (let from = 1; ; from += CHANNELS_PER_PAGE) {
      const data = await fetchChannels(from)
      if (!data) break

      const items = data.containers || []
      items.forEach(item => {
        const metadata = item.metadata
        if (!metadata) return

        channels.push({
          lang: LANGUAGES[metadata.channelLanguage] || 'fr',
          site_id: String(metadata.channelId),
          name: metadata.channelName
        })
      })

      if (!items.length || channels.length >= data.total) break
    }

    return channels
  }
}

function basePath(lang) {
  return BASE_PATH.replace('{locale}', LOCALES[lang] || LOCALES.nl)
}

function brusselsMidnight(date) {
  return dayjs.tz(date.format('YYYY-MM-DD'), TIMEZONE).startOf('d')
}

function fetchChannels(from) {
  return axios
    .get(`${API_ENDPOINT}${basePath('nl')}/TRAY/LIVECHANNELS`, {
      params: { from, to: from + CHANNELS_PER_PAGE - 1 },
      headers: {
        Origin: 'https://tv.pickx.be',
        Referer: 'https://tv.pickx.be/'
      }
    })
    .then(r => r.data.resultObj)
    .catch(console.error)
}

function parseImage(data) {
  const filename = data.pictureUrl || data.extendedMetadata?.images?.landscapePoster

  return filename ? `${API_IMAGE_ENDPOINT}/${filename}` : null
}

function parseItems(content) {
  if (!content) return []

  try {
    const data = JSON.parse(content)
    // the tray nests the programs of each requested channel under their own container
    const channel = data?.resultObj?.containers?.[0]

    return channel?.containers || []
  } catch {
    return []
  }
}
