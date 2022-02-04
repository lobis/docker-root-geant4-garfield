# Docker Image with ROOT, Geant4 and Garfield++

[![Build and Publish Docker Image](https://github.com/lobis/docker-root-geant4-garfield/actions/workflows/docker.yml/badge.svg)](https://github.com/lobis/docker-root-geant4-garfield/actions/workflows/docker.yml)
[![Verify Docker Image](https://github.com/lobis/docker-root-geant4-garfield/actions/workflows/verify.yml/badge.svg)](https://github.com/lobis/docker-root-geant4-garfield/actions/workflows/verify.yml)


This image has ROOT, Geant4 and Garfield++ installed. This repository hosts the Dockerfile as well as the Docker image as a GitHub Package.

---

## Usage

You don't need to build the image yourself since it is available as a [container package](https://github.com/lobis/docker-root-geant4-garfield/pkgs/container/root-geant4-garfield).

To use the latest version:

```
docker run -it ghcr.io/lobis/root-geant4-garfield:latest
```

There are other tags available [here](https://github.com/lobis/docker-root-geant4-garfield/pkgs/container/root-geant4-garfield/versions), which provide different combinations of C++ Standard / ROOT / Geant4 versions. For example, the tag built with C++17, ROOT v6-25-01 and Geant4 v11.0.0 is available as:

```
docker pull ghcr.io/lobis/root-geant4-garfield:cxx17_ROOTv6-25-01_Geant4v11.0.0
```

## Environment

ROOT, Geant4 and Garfield expects the user to load the required environment variables via the corresponding initialization scripts (such as `source $ROOTSYS/bin/thisroot.sh`). These lines are usually added to the `.bashrc` file.

In this image to load initialization scripts for ROOT, Geant4 and Garfield it is enough to input `source docker-entrypoint.sh`, which will load a script in `/usr/local/bin/docker-entrypoint.sh`. This is also appended to the `.bashrc` so that it loads automatically.

However when you are running a non interactive shell you may get an error. This is usually solved by doing `source docker-entrypoint.sh` manually.


## Build

If you want to build the image you need to pass the different versions as arguments:

```
CMAKE_CXX_STANDARD=17
ROOT_VERSION=v6-25-01
GEANT4_VERSION=v10.7.3
GARFIELD_VERSION=4.0

docker build --build-arg CMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD --build-arg ROOT_VERSION=$ROOT_VERSION --build-arg GEANT4_VERSION=$GEANT4_VERSION -t lobis/root-geant4-garfieldpp:cpp${CMAKE_CXX_STANDARD}_ROOT-${ROOT_VERSION}_Geant4-${GEANT4_VERSION}_Garfield-${GARFIELD_VERSION} .
```