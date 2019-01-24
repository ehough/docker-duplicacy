#!/bin/sh

set -e

cd /etc/duplicacy

if [ ! -f duplicacy.json ]; then
  echo '{}' > duplicacy.json
fi

if [ ! -f licenses.json ]; then
  echo '{}' > licenses.json
fi

if [ ! -f settings.json ]; then

  echo '{
  "listening_address"   : ":3875",
  "temporary_directory" : "/var/cache/duplicacy/repositories",
  "log_directory"       : "/var/log"
}' > settings.json
fi

# make the filters directory, if it doesn't already exist
mkdir -p filters

# switch to duplicacy_web
exec /usr/local/bin/duplicacy_web