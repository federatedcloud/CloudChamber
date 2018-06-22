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
#   - ability to install Docker 1.13+ and modify groups or
#   - ability to build and run docker containers as the current user
#   - 2G free disk space in the working directory
#   - 2G free disk space in the Docker system directories
#   - network access to download packages, code, data, images, etc.

which docker || {
  echo "Attempting to install Docker"
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker
}

CURRENT_USER="$(whoami)"
docker ps || {
  sudo usermod -aG docker "$CURRENT_USER"
}

CURRENT_DIRECTORY="$(pwd)"

echo "Running script $0 in $CURRENT_DIRECTORY"

if [ -d "$CURRENT_DIRECTORY/container-wrf" ]; then
  cd "container-wrf"
  git pull
  cd ..
else
  git clone https://github.com/NCAR/container-wrf
fi
cd ./container-wrf/3.7.1/datasets
cd wpsgeog ; docker build -t my-wpsgeog .
cd ../wrfinputsandy ; docker build -t my-wrfinputsandy .
cd ../../ncar-ncl ; docker build -t my-ncl .
cd ../ncar-wrf ; docker build -t my-wrf .
cd "$CURRENT_DIRECTORY"

docker create -v /WPS_GEOG --name wpsgeog my-wpsgeog
docker create -v /wrfinput --name wrfinputsandy my-wrfinputsandy
docker run -it --volumes-from wpsgeog --volumes-from wrfinputsandy -v "$CURRENT_DIRECTORY/wrfoutput:/wrfoutput" \
 --name mywrfsandy my-wrf /wrf/run-wrf
docker run -it --rm=true -v "$CURRENT_DIRECTORY/wrfoutput:/wrfoutput" --name postproc my-ncl

echo "Completed script successfully $0"
