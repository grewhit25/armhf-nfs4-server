# NFS v4 Server Container for Raspberry Pi 2/3

[![Docker Automated build](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)]()
[![Docker Build Status](https://img.shields.io/docker/build/jrottenberg/ffmpeg.svg)]()

This is a fork form: [Joe Bieillik nfs4 repo] (<https://github.com/jcbiellikltd/docker-nfs4>)
Modified to run on a Raspberry Pi and to auto load the exports configuration.
The auto load has been inspired by [Fuzzle] (<https://github.com/f-u-z-z-l-e/docker-nfs-server>)

[NFS v4](http://nfs.sourceforge.net/) server running under [s6 overlay](https://github.com/just-containers/s6-overlay) on [Alpine Linux](https://hub.docker.com/_/alpine/).

## Note

```text

Prerequisites
NFS needs to be installed on Linux systems in order to properly mount NFS mounts.

For Ubuntu/Debian: sudo apt-get install -y nfs-common
For RHEL/CentOS: sudo yum install -y nfs-utils
For Arch Linux: sudo pacman -S nfs-utils

It is recommend to try mounting an NFS volume to eliminate any configuration issues.

e.g.
sudo mount -v -o vers=4,loud <nfs-server>:/ ~/mnt

Things are different with NFSv4. The client must request a path relative to a virtual root directory on the server.
The exports entry with fsid=0 is the root directory.

```

## Configuration

See [example directory](https://github.com/grewhit25/docker-nfs4/tree/master/example) for sample config file.

## Quickstart

```yml
###### Server side container

docker run -d --cap-add=SYS_ADMIN \
  --name="nfs4" \
  --net=host \
  -v /mnt:/mnt \
  -e NFS_EXPORT_DIR_1=/mnt \
  -e NFS_EXPORT_DOMAIN_1=\* \
  -e NFS_EXPORT_OPTIONS_1="rw,fsid=0,root_squash,no_subtree_check,insecure" \
  -p 111:111 -p 111:111/udp \
  -p 2049:2049 -p 2049:2049/udp \
  restart:always \
  grewhit/armhf-nfs4-server

```

### docker-compose.yml

```yml
nfs4:
  image: grewhit/armhf-nfs4-server

    cap_add:
    - SYS_ADMIN

  volumes:
    # You can provide an exports config file or alternatively via environmental variables.
    - ./exports:/etc/exports

    # Default shares is /mnt if no exports provided
    - /mnt:/mnt

    # Alternative config method
  environment':'
    - NFS_EXPORT_DIR_1=/mnt
    - NFS_EXPORT_DOMAIN_1=\*
    - NFS_EXPORT_OPTIONS_1="rw,fsid=0,root_squash,no_subtree_check,insecure"

  ports:
    - "111:111/tcp"
    - "111:111/udp"
    - "2049:2049/tcp"
    - "2049:2049/udp"

###### Client side container

  docker run -d \
    --name=<container-name> \
    --net=host \
      --mount 'type=volume,src=<VOLUME-NAME>,dst=<CONTAINER-PATH>,\
      volume-driver=local,volume-opt=type=nfs,volume-opt=device=<nfs-server>:<nfs-path>,\
      "volume-opt=o=addr=<nfs-address>,vers=4,soft,timeo=180,bg,tcp,rw"' \
      --restart=always \
      image-to-run

```

## volumes

You will need to provide the server container with the volume(s) that you want to expose via nfs

-v /local-path:/path-in-container

## environment variables

To use the environmental variables, you will need to provide the following 3 environment variables to configure the nfs exports:

NFS_EXPORT_DIR_1
NFS_EXPORT_DOMAIN_1
NFS_EXPORT_OPTIONS_1

When the container is started, the environment variables are parsed and the following output is created in /etc/exports file:

NFS_EXPORT_DIR_1 NFS_EXPORT_DOMAIN_1(NFS_EXPORT_OPTIONS_1)

for the example above the following line would inserted in /etc/exports file

/mnt *(rw,fsid=0,root_squash,no_subtree_check,insecure)

which is also the default if no user exports or environmental variables are given.

To define multiple exports, just increment the index on the environment variables

### Mounting

Test you mount with either:

```shell
sudo mount -t nfs4 <nfs-server-address>:/ ~/mnt
sudo mount -v -o vers=4,loud <nfs-server>:/ ~/mnt
```
