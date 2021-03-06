#!/usr/bin/with-contenv bash

# placeholder script to distribute the cert to slave IPs

. /config/donoteditthisfile.conf

for job in $(echo "$SLAVEIPS" | tr "," " "); do
  . /config/distribute/"$job"/slave.conf
  ssh -i /config/distribute/"$job"/private -p "$SSHPORT" -oStrictHostKeyChecking=no "$SSHUSER"@"$job" rm -rf "$CONFIGPATH"/etc/letsencrypt
  rsync -avh -e "ssh -i /config/distribute/${job}/private -p ${SSHPORT} -oStrictHostKeyChecking=no" /config/etc/letsencrypt "$SSHUSER"@"$job":"$CONFIGPATH"/etc/
  ssh -i /config/distribute/"$job"/private -p "$SSHPORT" -oStrictHostKeyChecking=no "$SSHUSER"@"$job" 'docker exec -i fanartstatic chown -R abc:abc /config/etc/letsencrypt && docker exec -i fanartstatic s6-svc -h /var/run/s6/services/nginx'
done
