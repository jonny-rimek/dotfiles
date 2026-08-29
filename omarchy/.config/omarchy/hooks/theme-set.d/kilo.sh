#!/bin/bash

if pgrep -x kilo >/dev/null; then
  killall -SIGUSR2 kilo
fi
