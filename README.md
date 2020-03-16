![Gearbox](https://github.com/gearboxworks/gearbox.github.io/raw/master/Gearbox-100x.png)


# hugo Docker container service [Gearbox](https://github.com/gearboxworks/)
This is the repository for the [hugo](https://www.hugo.org/) Docker container implemented for [Gearbox](https://github.com/gearboxworks/).


## Repository Info
GitHub commit: ![commit-date](https://img.shields.io/github/last-commit/gearboxworks/docker-hugo?style=flat-square)

GitHub release(latest): ![last-release-date](https://img.shields.io/github/release-date/gearboxworks/docker-hugo) ![last-release-date](https://img.shields.io/github/v/tag/gearboxworks/docker-hugo?sort=semver) [![release-state](https://github.com/gearboxworks/docker-hugo/workflows/release/badge.svg?event=release)](https://github.com/gearboxworks/docker-hugo/actions?query=workflow%3Arelease)


## Supported versions and respective Dockerfiles
| Service | GitHub Version | Docker Version | Docker Size | Docker Tags |
| ------- | -------------- | -------------- | ----------- | ----------- |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.60.1-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.60.1) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.60.1) | _([`0.60.1`, `0.60`](https://github.com/gearboxworks/docker-hugo/blob/master/0.60/DockerfileRuntime))_ |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.62.2-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.62.2) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.62.2) | _([`0.62.2`, `0.62`](https://github.com/gearboxworks/docker-hugo/blob/master/0.62/DockerfileRuntime))_ |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.63.2-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.63.2) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.63.2) | _([`0.63.2`, `0.63`](https://github.com/gearboxworks/docker-hugo/blob/master/0.63/DockerfileRuntime))_ |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.64.1-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.64.1) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.64.1) | _([`0.64.1`, `0.64`](https://github.com/gearboxworks/docker-hugo/blob/master/0.64/DockerfileRuntime))_ |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.65.3-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.65.3) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.65.3) | _([`0.65.3`, `0.65`](https://github.com/gearboxworks/docker-hugo/blob/master/0.65/DockerfileRuntime))_ |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.66.0-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.66.0) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.66.0) | _([`0.66.0`, `0.66`](https://github.com/gearboxworks/docker-hugo/blob/master/0.66/DockerfileRuntime))_ |
| [hugo](https://www.hugo.org/) | ![hugo](https://img.shields.io/badge/hugo-0.67.1-green.svg) | ![Docker Version)](https://img.shields.io/docker/v/gearboxworks/hugo/0.67.1) | ![Docker Size](https://img.shields.io/docker/image-size/gearboxworks/hugo/0.67.1) | _([`0.67.1`, `0.67`, `latest`](https://github.com/gearboxworks/docker-hugo/blob/master/0.67/DockerfileRuntime))_ |


## Using this container.
This container has been designed to work within the [Gearbox](https://github.com/gearboxworks/)
framework.
However, due to the flexability of Gearbox, it can be used outside of this framework.
You can either use it directly from DockerHub or GitHub.


## Method 1: GitHub repo

### Setup from GitHub repo
Simply clone this repository to your local machine

`git clone https://github.com/gearboxworks/hugo-docker.git`

### Building from GitHub repo
`make build` - Build Docker images. Build all versions from the base directory or specific versions from each directory.

`make list` - List already built Docker images. List all versions from the base directory or specific versions from each directory.

`make clean` - Remove already built Docker images. Remove all versions from the base directory or specific versions from each directory.

`make push` - Push already built Docker images to Docker Hub, (only for Gearbox admins). Push all versions from the base directory or specific versions from each directory.

### Runtime from GitHub repo
When you `cd` into a version directory you can also perform a few more actions.

`make start` - Spin up a Docker container with the correct runtime configs.

`make stop` - Stop a Docker container.

`make run` - Run a Docker container in the foreground, (all STDOUT and STDERR will go to console). The Container be removed on termination.

`make shell` - Run a shell, (/bin/bash), within a Docker container.

`make rm` - Remove the Docker container.

`make test` - Will issue a `stop`, `rm`, `clean`, `build`, `create` and `start` on a Docker container.


## Method 2: Docker Hub

### Setup from Docker Hub
A simple `docker pull gearbox/hugo` will pull down the latest version.

### Starting
start - Spin up a Docker container with the correct runtime configs.

`docker run -d --name hugo-latest --restart unless-stopped --network gearboxnet gearbox/hugo:latest`

### Stopping
stop - Stop a Docker container.

`docker stop hugo-latest`

### Remove container
rm - Remove the Docker container.

`docker container rm hugo-latest`

### Run in foreground
run - Run a Docker container in the foreground, (all STDOUT and STDERR will go to console). The Container be removed on termination.

`docker run --rm --name hugo-latest --network gearboxnet gearbox/hugo:latest`

### Run a shell
shell - Run a shell, (/bin/bash), within a Docker container.

`docker run --rm --name hugo-latest -i -t --network gearboxnet gearbox/hugo:latest /bin/bash`

### SSH
ssh - All [Gearbox](https://github.com/gearboxworks/) containers have a running SSH daemon. So you can connect remotely.

```
SSH_PORT="$(docker port hugo-latest 22/tcp | sed 's/0.0.0.0://')"
ssh -p ${SSH_PORT} -o StrictHostKeyChecking=no gearbox@localhost
```

