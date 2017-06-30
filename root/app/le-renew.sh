#!/usr/bin/with-contenv bash

. /config/donoteditthisfile.conf

if [ "$ORIGVALIDATOR" = "true" ]; then
  echo "<------------------------------------------------->"
  echo
  echo "<------------------------------------------------->"
  echo "cronjob running on "$(date)
  echo "Running certbot renew"
  certbot -n renew --webroot -w /config/www --post-hook "/config/distribute/distribute.sh"
fi
