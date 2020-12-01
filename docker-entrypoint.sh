#!/usr/bin/env bash
set -e
echo "/docker-entrypoint.sh start..."

# Source files in docker-entrypoint.d/ dump directory
IFS=$'\n' eval 'for f in $(find /docker-entrypoint.d/ -type f -print |sort); do source ${f}; done'

echo "CMD $@"
exec $@
