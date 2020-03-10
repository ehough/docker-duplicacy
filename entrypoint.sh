#!/bin/sh

# Copyright (c) 2019-2020 Eric D. Hough <eric@tubepress.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
