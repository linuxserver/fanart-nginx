#!/usr/bin/with-contenv bash

. /config/donoteditthisfile.conf

if [ "$VALIDATOR" = "true" ]; then
  echo "<------------------------------------------------->"
  echo
  echo "<------------------------------------------------->"
  echo "cronjob running on "$(date)
  echo "Running certbot renew"
  certbot -n renew --webroot -w /config/www --post-hook "sh /app/distribute.sh"
fi
