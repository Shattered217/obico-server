#!/usr/bin/env bash
set -euo pipefail

# Build base image for Jetson
sudo docker build -f Dockerfile.base_arm64 -t obico-ml-api-base:jetson .

# Build main ml-api image for Jetson
sudo docker build -f Dockerfile -t obico-ml-api:jetson .
