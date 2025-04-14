#!/bin/bash

# Loop through arguments
for arg in "$@"; do
   case "$arg" in
      chron-schedule=*) chron_schedule="${arg#*=}" ;;
      work-dir=*) work_dir="${arg#*=}" ;;
      days=*) days="${arg#*=}" ;;
      delay=*) delay="${arg#*=}" ;;
      max_connections=*) max_connections="${arg#*=}" ;;
      enable_fixes=*) enable_fixes="${arg#*=}" ;;
	   api_url=*) api_url="${arg#*=}" ;;
   esac
done

echo "chron_schedule : ${chron_schedule}"
cd $work_dir
echo "working dir : " $(pwd)
echo "days : ${days}"
echo "delay : ${delay}"
echo "max_connections : ${max_connections}"
echo "enable_fixes : ${enable_fixes}"
echo "api url : ${api_url}"

if [ "$enable_fixes" = true ] ; then
 cp -R /fixes/* /bin/epg/sites/
fi

sed -i -E "s/(https:\x2f\x2fiptv-org.github.io\x2fapi$\123filename\125)/$api_url$\123filename\125/g" $work_dir/scripts/core/apiClient.ts
ln -s $work_dir/guide.xml /public/guide.xml
ln -s $work_dir/guide.xml.gz /public/guide.xml.gz
pm2-runtime pm2.config.js --name epg --node-args="--no-autorestart --cron-restart="$chron_schedule" --maxConnections=$max_connections --days=$days --delay=$delay"  