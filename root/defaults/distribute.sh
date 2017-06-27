#!/usr/bin/with-contenv bash

# placeholder script to distribute the cert to slave IPs

. /config/donoteditthisfile.conf

for job in $(echo "$SLAVEIPS" | tr "," " "); do
  . /config/distribute/"$job"/slave.conf
  ssh -i /config/distribute/"$job"/private -p "$SSHPORT" -oStrictHostKeyChecking=no "$SSHUSER"@"$job" 'rm -rf "$CONFIGPATH"/etc/letsencrypt'
  scp -i /config/distribute/"$job"/private -P "$SSHPORT" -oStrictHostKeyChecking=no -r /config/etc/letsencrypt "$SSHUSER"@"$job":"$CONFIGPATH"/etc/letsencrypt
  ssh -i /config/distribute/"$job"/private -p "$SSHPORT" -oStrictHostKeyChecking=no "$SSHUSER"@"$job" 'docker exec -i chown -R abc:abc /config/etc/letsencrypt && fanartstatic s6-svc -h /var/run/s6/services/nginx'
done
