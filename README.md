[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

## This is a Container in active development by the [LinuxServer.io][linuxserverurl] team and is not recommended for use by the general public.

If you want to comment\contribute on this container , are looking for support on any of our other work , or are curious about us in general, check out the following.

* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

## Usage

### Validator server
```
docker create \
  --privileged \
  --name=fanartstatic \
  -v <path to data>:/config \
  -e PGID=<gid> -e PUID=<uid>  \
  -e EMAIL=<email> \
  -e URL=<url> \
  -p 80:80 -p 443:443 \
  -e TZ=<timezone> \
  -e VALIDATOR=<true> \
  -e SLAVEIPS=<IPs,comma,separated> \
  lsiodev/fanart-nginx
```

### Slave Server
```
docker create \
  --privileged \
  --name=fanartstatic \
  -v <path to data>:/config \
  -e PGID=<gid> -e PUID=<uid>  \
  -e URL=<url> \
  -p 80:80 -p 443:443 \
  -e TZ=<timezone> \
  -e VALIDATOR=<false> \
  -e VALIDATORIP=<ipaddress> \
  lsiodev/fanart-nginx
```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `-p 80 -p 443` - the port(s)
* `-v /config` - all the config files including the webroot reside here
* `-e URL` - the url for server
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` - timezone ie. `America/New_York`  
* `-e VALIDATOR` - determines whether the server should run letsencrypt
* `-e VALIDATORIP` - mandatory for slave servers
* `-e SLAVEIPS` - IPs for cert distribution, comma separated, no spaces. Required for cert distribution to slaves. Leave out in a single server scenario.
  
_Optional settings:_
* `-e EMAIL` - your e-mail address for cert registration and notifications
* `-e DHLEVEL` - dhparams bit value (default=2048, can be set to `1024` or `4096`)


It is based on alpine linux with s6 overlay, for shell access whilst the container is running do `docker exec -it letsencrypt /bin/bash`.

## Multiple server setup instructions
### Adding a new slave
* Create the slave container and start it.
* The container will stop after generating the DH parameter due to not existing cert.
* Add the public ssh key to new slave's `authorized_keys`
* On the validator, create a new folder for the slave info and copy the sample.conf `cp -R /config-folder-path/distribute/XX.XX.XX.XX /config-folder-path/distribute/<new.slave.ip.address>`
* Edit the sample.conf with the new slave details
* Copy the private ssh key into the folder with the name `private` (no password)
* Recreate the validator container with the new slave's IP address added into the `SLAVEIPS` variable
* Restart the new slave
* Add the new slave to the round robin dns

### Removing a slave
* Remove the slave from the round robin DNS
* Remove the slave container
* Recreate the validator with the slave's IP removed from the `SLAVEIPS` variable

### Switching the validator to a different server
* Recreate all other slaves with the `VALIDATORIP` changed to reflect the new validator server
* Remove the old validator from the round robin DNS
* Add the new validator to round robin DNS
* Create the new validator container (initially with no `SLAVEIPS` defined so folders are created)
* Create the slave IP named folders under /config/distribute for each slave, with their sample.conf and private ssh keys (as described above)
* Recreate the new validator with the slave IPs defined
