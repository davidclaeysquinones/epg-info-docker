FROM node:21-alpine
ARG GIT_REPO=https://github.com/iptv-org/epg.git
ARG GIT_BRANCH=master
ENV CRON_SCHEDULE="0 0,12 * * *"
ENV DAYS=14
ENV MAX_CONNECTIONS=10
ARG BIN_FOLDER=/bin
ARG EPG_FOLDER=epg
ARG START_SCRIPT_ARG=$BIN_FOLDER/$EPG_FOLDER/start.sh
ENV WORKDIR=${BIN_FOLDER}/${EPG_FOLDER}
ENV START_SCRIPT=$START_SCRIPT_ARG
COPY channels.xml /config/channels.xml
RUN apk update \
    && apk upgrade --available \
	  && apk add curl \
    && apk add git \
    && apk add tzdata \
    && apk add bash \
    && npm install -g npm@latest \
    && npm install pm2 -g \
    && mkdir $(echo "${BIN_FOLDER}/${EPG_FOLDER}") -p \
    && git -C $(echo "${BIN_FOLDER}") clone --depth 1 -b $(echo "${GIT_BRANCH} ${GIT_REPO}") \
    && cd $WORKDIR cat && npm install && npm update \
    && rm .eslintrc.json \
    && rm -rf .github \
    && rm -rf .git \
    && rm .gitignore  \
    && rm CONTRIBUTING.md  \
    && rm LICENSE \
    && rm README.md \
    && rm SITES.md \
    && ln -s /config/channels.xml $(echo "${WORKDIR}/channels.xml") \
    && mkdir /public
COPY start.sh $WORKDIR
COPY serve.json $WORKDIR
RUN chmod +x "$START_SCRIPT" \
  && apk del git curl \
  && rm -rf /var/cache/apk/*
ENTRYPOINT bash $START_SCRIPT chron-schedule="$CRON_SCHEDULE" work-dir="$WORKDIR" days="$DAYS" max_connections="$MAX_CONNECTIONS"
EXPOSE 3000