#!/bin/bash

# Load exports if user defined
if [ -z "$NFS_EXPORT_DIR_1" ]; then
  echo "Loading default exports"
  echo "/mnt *(rw,fsid=0,root_squash,no_subtree_check,insecure)" > /etc/exports
else
# Loading user exports
  /app/configure-exports.bash
fi
echo $(cat /etc/exports)

exec "$@"