# Private Registry NCAR WRF Demo

## Prerequisites

Tested on Ubuntu 16.04 with Docker engine v18.03.

See demo run script for more detailed requirements.

### Install Docker

https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/

These instructions should install Docker CE version 18.03 or later.

### Launch a Docker Private Registry

Open source and free of charge

https://docs.docker.com/registry/deploying/#more-advanced-authentication

https://github.com/docker/docker.github.io/blob/master/registry/deploying.md

Script below expects one test user created with htpasswd basic auth whose password is temporarily stored in $HOME/.docker_pass .

### Build, Tag, and Push NCAR WRF Docker Demo Images

[NCAR WRF Demo](https://github.com/NCAR/container-wrf)

Check the script later to make sure image names agree.

### Copy and Configure Environment

Copy and edit ncar-wrf-env.sh.template to ncar-wrf-env.sh

## Usage

```
git clone https://github.com/federatedcloud/CloudChamber.git
cd CloudChamber/private-registry-demo
source ncar-wrf-env.sh
./run-ncar-wrf-private-registry-demo.sh
```

After some execution time expect to see

```
Completed script successfully ./run-ncar-wrf-private-registry-demo.sh
```

