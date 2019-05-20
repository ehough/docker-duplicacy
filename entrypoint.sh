#!/bin/sh

set -e

log() {

  echo "----> $1"
}

assert_file() {

  if [ ! -f "$2" ]; then
    log "staging initial $2"
    echo "$1" > "$2"
  fi
}

log_hostname() {

  log "container hostname is $(hostname)"
}

# Duplicacy will look for a machine-id at /var/lib/dbus/machine-id, so we need to make sure that something is there
assert_machine_id() {

  local path=/var/lib/dbus/machine-id

  # did they bind-mount it in?
  if mount | grep -Eq "^[^ ]+ on $path type "; then
    log "$path is bind-mounted"
    return
  fi

  # maybe it's baked-in to the image
  if [ -f $path ] && [ -r $path ] && [ -s $path ]; then
    log "$path is baked-in to the image"
    return
  fi

  # maybe they provided it as an environment variable
  if [ -n "$MACHINE_ID" ]; then
    log "using machine-id from MACHINE_ID environment variable: $MACHINE_ID"
    echo "$MACHINE_ID" > $path
    return
  fi

  # no luck. generate a temporary machine-id
  cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1 > $path
  log "using temporary, random machine-id of $(cat $path)"
}

stage_duplicacy_directory() {

  cd /etc/duplicacy

  assert_file '{}' 'duplicacy.json'
  assert_file '{}' 'licenses.json'
  assert_file '{
  "listening_address"   : ":3875",
  "temporary_directory" : "/var/cache/duplicacy/repositories",
  "log_directory"       : "/var/log"
}' 'settings.json'

  # make the filters and stats directories, if they don't already exist
  mkdir -p filters /var/cache/duplicacy/stats
}

start_duplicacy() {

  log 'starting duplicacy_web'
  exec /usr/local/bin/duplicacy_web
}

log_hostname
assert_machine_id
stage_duplicacy_directory
start_duplicacy
