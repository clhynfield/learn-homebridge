#!/bin/bash

if [ ! -f .ci-loop.swp ]; then touch .ci-loop.swp; fi

while true; do
  if find . -name '*.bats' -newer .ci-loop.swp | grep .; then
    make test
    touch .ci-loop.swp
  fi
  sleep 1
done
