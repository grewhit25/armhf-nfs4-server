# NFS v4 Server Container for Raspberry Pi 2/3

This is a fork form: https://github.com/jcbiellikltd/docker-nfs4
Modified to run on a Raspberry Pi and to auto load the exports configuration.
The auto load has been inspired by Fuzzle: https://github.com/f-u-z-z-l-e/docker-nfs-server

[NFS v4](http://nfs.sourceforge.net/) server running under [s6 overlay](https://github.com/just-containers/s6-overlay) on [Alpine Linux](https://hub.docker.com/_/alpine/).

## Configuration
See [example directory](https://github.com/grewhit25/docker-nfs4/tree/master/example) for sample config file.

## Quickstart

docker run -d --cap-add=SYS_ADMIN \
  --name="nfs4" \
  --net=host \
  -v /mnt:/mnt \
  -e NFS_EXPORT_DIR_1=/mnt \
  -e NFS_EXPORT_DOMAIN_1=\* \
  -e NFS_EXPORT_OPTIONS_1="rw,fsid=0,root_squash,no_subtree_check,insecure" \
  -p 111:111 -p 111:111/udp \
  -p 2049:2049 -p 2049:2049/udp \
  restart:always
  grewhit/armhf-nfs4-server

docker-compose.yml

nfs4:
  image: grewhit/armhf-nfs4-server

  # Required to load kernel NFS module
  cap_add:
    - SYS_ADMIN

  volumes:
    # You can provide an exports config file or alternatively via environmental variables.
    - ./exports:/etc/exports

    # Default shares is /mnt if no exports provided
    - /mnt:/mnt

    # Alternative config method
  environment:
    - NFS_EXPORT_DIR_1=/mnt \
    - NFS_EXPORT_DOMAIN_1=\* \
    - NFS_EXPORT_OPTIONS_1="rw,fsid=0,root_squash,no_subtree_check,insecure"

  ports:
    - "111:111/tcp"
    - "111:111/udp"
    - "2049:2049/tcp"
    - "2049:2049/udp"

volumes

You will need to provide the container with the volume(s) that you want to expose via nfs

-v <local path>:<path in container>

environment variables
To use the environmental variable method, you will need to provide at the following 3 environment variables to configure the nfs exports:

NFS_EXPORT_DIR_1
NFS_EXPORT_DOMAIN_1
NFS_EXPORT_OPTIONS_1

When the container is started, the environment variables are parsed and the following output is created in /etc/exports file:

NFS_EXPORT_DIR_1 NFS_EXPORT_DOMAIN_1(NFS_EXPORT_OPTIONS_1)

for the example above  the following line in /etc/exports would be created:

/mnt *(rw,fsid=0,root_squash,no_subtree_check,insecure)

which is also the default if no user exports or environmental variables are given.

To define multiple exports, just increment the index on the environment variables

### Mounting

```shell
mount -t nfs4 <nfs-server-address>:/ ./nfs
```

