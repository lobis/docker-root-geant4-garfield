ARG CMAKE_CXX_STANDARD
ARG ROOT_VERSION
ARG GEANT4_VERSION
ARG GARFIELD_VERSION

FROM ubuntu:22.04

LABEL maintainer.name="Luis Antonio Obis Aparicio"
LABEL maintainer.email="luis.antonio.obis@gmail.com"

LABEL org.opencontainers.image.source="https://github.com/lobis/docker-root-geant4-garfield"

ARG APPS_DIR=/usr/local

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get install -y \
    apt binutils build-essential cmake wget curl zstd davix-dev dcap-dev xdg-utils fonts-freefont-ttf g++ gcc gfortran clang-format \
    git libafterimage-dev libcfitsio-dev libexpat-dev libfcgi-dev libfftw3-dev libfreetype6-dev libftgl-dev libgfal2-dev libgif-dev \
    libgl2ps-dev libglew-dev libglu-dev libgraphviz-dev libgsl-dev libjpeg-dev liblz4-dev liblzma-dev libmpc-dev libmysqlclient-dev  \
    libpcre++-dev libpng-dev libpq-dev libspdlog-dev libsqlite3-dev libssl-dev libtbb-dev libtiff-dev libx11-dev \
    libxerces-c-dev libxext-dev libxft-dev libxml2-dev libxmu-dev libxpm-dev libxxhash-dev libz-dev libzstd-dev make openssl \
    python3-dev python3-pip python-is-python3 ntp software-properties-common srm-ifce-dev unixodbc-dev \
    libpq-dev postgresql-server-dev-all libboost-all-dev libcurl4-openssl-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/cache/apt/archives/* && \
    rm -rf /var/lib/apt/lists/*

ARG CMAKE_CXX_STANDARD=17
ENV CMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
RUN echo CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}

# ROOT
ARG ROOT_VERSION=master
ENV ROOT_VERSION=${ROOT_VERSION}
RUN echo ROOT_VERSION: ${ROOT_VERSION}

RUN git clone https://github.com/root-project/root.git $APPS_DIR/root/source --branch=${ROOT_VERSION} && \
    cd $APPS_DIR/root/source && \
    mkdir -p $APPS_DIR/root/build &&  cd $APPS_DIR/root/build && \
    cmake $APPS_DIR/root/source -DCMAKE_INSTALL_PREFIX=$APPS_DIR/root/install -DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD -Dbuiltin_afterimage=ON -Dgnuinstall=ON && \
    make -j$(nproc) install && \
    rm -rf $APPS_DIR/root/build $APPS_DIR/root/source

ENV ROOTSYS $APPS_DIR/root/install
ENV PATH $APPS_DIR/root/install/bin:$PATH
ENV LD_LIBRARY_PATH $APPS_DIR/root/install/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH $APPS_DIR/root/install/lib:$PYTHONPATH

# GARFIELD
ARG GARFIELD_VERSION=master
ENV GARFIELD_VERSION=${GARFIELD_VERSION}
RUN echo GARFIELD_VERSION: ${GARFIELD_VERSION}

RUN git clone https://gitlab.cern.ch/garfield/garfieldpp.git $APPS_DIR/garfieldpp/source && \
    cd $APPS_DIR/garfieldpp/source && git reset --hard ${GARFIELD_VERSION} && \
    mkdir -p $APPS_DIR/garfieldpp/build &&  cd $APPS_DIR/garfieldpp/build && \
    cmake ../source/ -DCMAKE_INSTALL_PREFIX=$APPS_DIR/garfieldpp/install \
    -DWITH_EXAMPLES=OFF -DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD && \
    make -j$(nproc) install && \
    rm -rf $APPS_DIR/garfieldpp/build $APPS_DIR/garfieldpp/source

ENV GARFIELD_INSTALL $APPS_DIR/garfieldpp/install
ENV CMAKE_PREFIX_PATH=$APPS_DIR/garfieldpp/install:$CMAKE_PREFIX_PATH
ENV HEED_DATABASE $APPS_DIR/garfieldpp/install/share/Heed/database
ENV LD_LIBRARY_PATH $APPS_DIR/garfieldpp/install/lib:$LD_LIBRARY_PATH
ENV ROOT_INCLUDE_PATH $APPS_DIR/garfieldpp/install/include:$ROOT_INCLUDE_PATH
ENV ROOT_INCLUDE_PATH $APPS_DIR/garfieldpp/install/include/Garfield:$ROOT_INCLUDE_PATH

# GEANT4
ARG GEANT4_VERSION=master
ENV GEANT4_VERSION=${GEANT4_VERSION}
RUN echo GEANT4_VERSION: ${GEANT4_VERSION}

RUN git clone https://github.com/Geant4/geant4.git $APPS_DIR/geant4/source --branch=${GEANT4_VERSION} && \
    cd $APPS_DIR/geant4/source && \
    mkdir -p $APPS_DIR/geant4/build &&  cd $APPS_DIR/geant4/build && \
    cmake ../source/ -DCMAKE_INSTALL_PREFIX=$APPS_DIR/geant4/install -DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD -DGEANT4_BUILD_CXXSTD=$CMAKE_CXX_STANDARD \
    -DGEANT4_BUILD_MULTITHREADED=ON -DGEANT4_USE_QT=ON -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_RAYTRACER_X11=ON \
    -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML=ON && \
    make -j$(nproc) install && \
    rm -rf $APPS_DIR/geant4/build $APPS_DIR/geant4/source

ENV PATH $APPS_DIR/geant4/install/bin:$PATH
ENV LD_LIBRARY_PATH $APPS_DIR/geant4/install/lib:$LD_LIBRARY_PATH

# Version command
RUN echo "#!/bin/bash" >> /version.sh
RUN echo "echo '- CMAKE_CXX_STANDARD: $CMAKE_CXX_STANDARD'" >> /version.sh
RUN echo "echo '- ROOT_VERSION: $ROOT_VERSION'" >> /version.sh
RUN echo "echo '- GEANT4_VERSION: $GEANT4_VERSION'" >> /version.sh
RUN echo "echo '- GARFIELD_VERSION: $GARFIELD_VERSION'" >> /version.sh
RUN chmod +x /version.sh
RUN mv /version.sh /usr/local/bin/version.sh

LABEL org.opencontainers.image.description="ROOT, Geant4 and Garfield++ on Ubuntu 22.04"

# Entrypoint
RUN echo "#!/bin/bash" >> /docker-entrypoint.sh
RUN echo "source $APPS_DIR/root/install/bin/thisroot.sh" >> /docker-entrypoint.sh
RUN echo "source $APPS_DIR/garfieldpp/install/share/Garfield/setupGarfield.sh" >> /docker-entrypoint.sh
RUN echo "source $APPS_DIR/geant4/install/bin/geant4.sh" >> /docker-entrypoint.sh
RUN echo "exec \"\$@\"" >> /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
RUN mv /docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN echo "source docker-entrypoint.sh" >> ~/.bashrc

WORKDIR /

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/bin/bash"]
