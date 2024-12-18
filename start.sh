#!/bin/bash

# Loop through arguments
for arg in "$@"; do
   case "$arg" in
      chron-schedule=*) chron_schedule="${arg#*=}" ;;
      work-dir=*) work_dir="${arg#*=}" ;;
      days=*) days="${arg#*=}" ;;
      max_connections=*) max_connections="${arg#*=}" ;;
      enable_fixes=*) enable_fixes="${arg#*=}" ;;
	  api_url=*) api_url="${arg#*=}" ;;
   esac
done

echo "chron_schedule : ${chron_schedule}"
cd $work_dir
echo "working dir : " $(pwd)
echo "days : ${days}"
echo "max_connections : ${max_connections}"
echo "enable_fixes : ${enable_fixes}"
echo "api url : ${api_url}"

if [ "$enable_fixes" = true ] ; then
 cp -R /fixes/* /bin/epg/sites/
fi

sed -i -E "s/(https:\x2f\x2fiptv-org.github.io\x2fapi)/$api_url/g" $work_dir/scripts/core/apiClient.ts

pm2 --name epg start npm run serve
npm run grab --- --channels=channels.xml --maxConnections=$max_connections --days=$days --gzip
ln -s $work_dir/guide.xml /public/guide.xml
ln -s $work_dir/guide.xml.gz /public/guide.xml.gz
npm run grab --- --channels=channels.xml --cron="$chron_schedule" --maxConnections=$max_connections --days=$days --gzip