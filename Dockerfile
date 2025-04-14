FROM node:22-alpine
ARG GIT_REPO=https://github.com/iptv-org/epg.git
ARG GIT_BRANCH=master
ENV CRON_SCHEDULE="0 0,12 * * *"
ENV API_URL="https://iptv-org.github.io/api"
ENV DAYS=14
ENV DELAY=0
ENV MAX_CONNECTIONS=10
ENV ENABLE_FIXES=false
ARG BIN_FOLDER=/bin
ARG EPG_FOLDER=epg
ARG FIXES_FOLDER_ARG=fixes
ARG START_SCRIPT_ARG=$BIN_FOLDER/$EPG_FOLDER/start.sh
ENV WORKDIR=${BIN_FOLDER}/${EPG_FOLDER}
ENV FIXES_FOLDER=$FIXES_FOLDER_ARG
ENV START_SCRIPT=$START_SCRIPT_ARG
COPY channels.xml /config/channels.xml
ADD $FIXES_FOLDER /fixes
RUN apk update \
    && apk upgrade --available \
	  && apk add curl git tzdata bash \
    && npm install -g npm@latest \
    && npm install pm2 -g \
    && mkdir $(echo "${BIN_FOLDER}/${EPG_FOLDER}") -p \
    && git -C $(echo "${BIN_FOLDER}") clone --depth 1 -b $(echo "${GIT_BRANCH} ${GIT_REPO}") \
    && cd $WORKDIR && npm install && npm update \ 
    && rm -rf .sites \
    && rm -rf .husky \
    && rm -rf .github \
    && rm -rf .git \
    && rm .gitignore  \
    && rm CONTRIBUTING.md  \
    && rm LICENSE \
    && rm README.md \
    && rm SITES.md \
    && rm -rf tests \
    && rm sites/**/readme.md \
    && rm -rf sites/**/__data__ \
    && rm sites/**/**.test.js \
    && rm -rf node_modules/**/.package-lock.json \
    && rm -rf node_modules/**/.tsconfig.json \
    && rm -rf node_modules/**/.tsconfig.tsbuildinfo.json \
    && rm -rf node_modules/**/.github \
    && rm -rf node_modules/**/docs \
    && rm -rf node_modules/**/LICENSE \
    && rm -rf node_modules/**/license \
    && rm -rf node_modules/**/**.md \
    && rm -rf node_modules/**/**/LICENSE \
    && rm -rf node_modules/**/**/license \
    && rm -rf node_modules/**/**/.github \
    && rm -rf node_modules/**/**/**.md \
    && ln -s /config/channels.xml $(echo "${WORKDIR}/channels.xml") \
    && mkdir /public
COPY start.sh $WORKDIR
COPY serve.json $WORKDIR
COPY pm2.config.js $WORKDIR
RUN chmod +x "$START_SCRIPT" \
  && apk del git curl \
  && rm -rf /var/cache/apk/*
SHELL ["/bin/bash", "-c"]
ENTRYPOINT bash $START_SCRIPT chron-schedule="$CRON_SCHEDULE" work-dir="$WORKDIR" days="$DAYS" delay=$DELAY max_connections="$MAX_CONNECTIONS" enable_fixes="$ENABLE_FIXES" api_url="$API_URL"
EXPOSE 3000