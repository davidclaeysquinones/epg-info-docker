FROM node:21-alpine
ARG GIT_REPO=https://github.com/iptv-org/epg.git
ARG GIT_BRANCH=master
ENV CRON_SCHEDULE="0 0,12 * * *"
ENV DAYS=14
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
    && rm -rf tests \
    && rm sites/**/readme.md \
    && rm -rf sites/**/__data__ \
    && rm sites/**/**.test.js \
    && ln -s /config/channels.xml $(echo "${WORKDIR}/channels.xml") \
    && mkdir /public
COPY start.sh $WORKDIR
COPY serve.json $WORKDIR
RUN chmod +x "$START_SCRIPT" \
  && apk del git curl \
  && rm -rf /var/cache/apk/*
SHELL ["/bin/bash", "-c"]
ENTRYPOINT bash $START_SCRIPT chron-schedule="$CRON_SCHEDULE" work-dir="$WORKDIR" days="$DAYS" max_connections="$MAX_CONNECTIONS" enable_fixes="$ENABLE_FIXES"
EXPOSE 3000