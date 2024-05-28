#!/usr/bin/env bash
set -eo pipefail

sudo waydroid shell settings put system force_mouse_as_touch "$1"
