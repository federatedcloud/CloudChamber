#!/bin/bash

set -eu
set -o pipefail

# Note:  Not intended to be run on super computers or clusters where docker engine may not be running.
# these are tutorial steps for learning on a personal workstation or laptop where Docker engine
# has been installed and running.
#
# These are mildly automated steps to build your personal docker wrf container images and run a short test.
#
# Requirements:
#   - system OS Ubuntu LTS Latest
#   - default system bash shell or compatible shell
#   - ability to install Docker 1.13+ (18.03 tested) and modify groups or
#   - ability to build and run docker containers as the current user
#   - 2G free disk space in the working directory
#   - 2G free disk space in the Docker system directories
#   - network access to download packages, code, data, images, etc.
#   - Docker open source private registry running
#   - access credentials to complete docker login on private registry

which docker || {
  echo "Attempting to install Docker"
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker
}

CURRENT_USER="$(whoami)"
docker ps || {
  sudo usermod -aG docker "$CURRENT_USER"
}

[ -f "$HOME/.docker_pass" ] || {
  echo "Please configure docker login information in $HOME/.docker_pass or modify this script"
  exit 1
}

echo "Using Docker private registry $PRIVATE_REGISTRY_DOMAIN"

cat "$HOME/.docker_pass" | docker login "$PRIVATE_REGISTRY_DOMAIN" --username "$DOCKER_USERNAME" --password-stdin
export WRF_IMAGE="$PRIVATE_REGISTRY_DOMAIN/ncar-wrf"
export NCL_IMAGE="$PRIVATE_REGISTRY_DOMAIN/ncar-ncl"
export WRF_INPUT_SANDY_IMAGE="$PRIVATE_REGISTRY_DOMAIN/ncar-wrfinputsandy"
export WPSGEOG_IMAGE="$PRIVATE_REGISTRY_DOMAIN/ncar-wpsgeog"

CURRENT_DIRECTORY="$(pwd)"

echo "Running script $0 in $CURRENT_DIRECTORY"

if [ -d "$CURRENT_DIRECTORY/container-wrf" ]; then
  cd "container-wrf"
  git pull
  cd ..
else
  git clone https://github.com/NCAR/container-wrf
fi
cd "$CURRENT_DIRECTORY"

docker ps -a | grep wpsgeog || docker create -v /WPS_GEOG --name wpsgeog "$WPSGEOG_IMAGE"
docker ps -a | grep wrfinputsandy || docker create -v /wrfinput --name wrfinputsandy "$WRF_INPUT_SANDY_IMAGE"
docker ps -a | grep ncarwrfsandy && docker rm -fv ncarwrfsandy
docker run -it --volumes-from wpsgeog --volumes-from wrfinputsandy \
    -v "$CURRENT_DIRECTORY/wrfoutput:/wrfoutput" \
    --name ncarwrfsandy "$WRF_IMAGE" /wrf/run-wrf
docker ps -a | grep postproc && docker rm -fv postproc
docker run -it --rm=true -v "$CURRENT_DIRECTORY/wrfoutput:/wrfoutput" --name postproc "$NCL_IMAGE"

echo "Completed script successfully $0"
