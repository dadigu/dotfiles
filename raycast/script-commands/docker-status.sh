#!/bin/bash

# Dependency: This script requires `docker for mac` to be installed: https://docs.docker.com/docker-for-mac/install/
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Container status
# @raycast.mode fullOutput
#
# Optional parameters:
# @raycast.icon icons/docker.png
# @raycast.packageName Docker
#
# @raycast.description Get status of running containers
# @raycast.author Dx

if ! command -v docker &> /dev/null; then
      echo "docker for mac is required (https://docs.docker.com/docker-for-mac/install/).";
      exit 1;
fi

docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" --no-stream