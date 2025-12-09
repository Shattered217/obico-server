#!/usr/bin/env bash
set -euo pipefail

TOKEN=${ML_API_TOKEN:-bambu_nb}

sudo docker run -it --rm \
  --runtime nvidia \
  --network host \
  -p 3333:3333 \
  -e ML_API_TOKEN="${TOKEN}" \
  obico-ml-api:jetson "$@"
