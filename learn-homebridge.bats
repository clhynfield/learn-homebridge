#!/bin/bash

dev_mode() {
    [ "$LIFECYCLE" == 'development' ]
}

if dev_mode; then
    exec 4>&3
else
    exec 4>/dev/null
fi

setup() {
    mkdir -p "$BATS_TMPDIR/homebridge"
    touch "$BATS_TMPDIR/homebridge/lifecycle-$LIFECYCLE"
}

teardown() {
    ls -al "$BATS_TMPDIR/homebridge" >&4
    echo rm -rf "$BATS_TMPDIR/homebridge" >&4
}

@test "Running Homebridge container for the first time creates a config" {
    if ! dev_mode; then skip; fi
    homebridge_home="$BATS_TMPDIR/homebridge"
    run docker run \
      --volume "$homebridge_home:/homebridge" \
      --env "PUID=$UID" --env "PGID=$GID" \
      --name 'homebridge' --rm \
      'oznu/homebridge:debian' \
      true
    [ "$status" -eq 0 ]
    echo "$output" | sed 's/^/# /g' >&4
    [ -f "$homebridge_home/config.json" ]
}

@test "Running Homebridge provides a HomeKit bridge" {
    homebridge_home="$BATS_TMPDIR/homebridge"
    run docker run \
      --net='host' \
      --name='homebridge' --rm \
      --volume "$homebridge_home:/homebridge" \
      --env "PUID=$UID" --env "PGID=$GID" \
      --detach \
      'oznu/homebridge:debian'
    echo "Please wait while Homebridge starts up" | sed 's/^/# /g' >&3
    echo "Homebridge should now be running" | sed 's/^/# /g' >&3
    echo "Try adding it to your HomeKit configuration" | sed 's/^/# /g' >&3
    sleep 120
    [ "$status" -eq 0 ]
    echo "$output" | sed 's/^/# /g' >&4
    [ -f "$homebridge_home/config.json" ]
}
