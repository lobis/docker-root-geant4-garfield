FROM ubuntu:latest

LABEL maintainer.name="Luis Obis"
LABEL maintainer.email="luis.antonio.obis@gmail.com"

LABEL org.opencontainers.image.source="https://github.com/lobis/docker-root-geant4-garfield"

ARG CMAKE_CXX_STANDARD=17
ARG ROOT_VERSION=master
ARG GEANT4_VERSION=master
ARG GARFIELD_VERSION=master

LABEL org.opencontainers.image.description="ROOT (${ROOT_VERSION}), \
    Geant4 (${GEANT4_VERSION}) and \
    Garfield (${GARFIELD_VERSION}) \
    compiled with C++${CMAKE_CXX_STANDARD}.\
    "

RUN echo CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}
RUN echo ROOT_VERSION: ${ROOT_VERSION}
RUN echo GEANT4_VERSION: ${GEANT4_VERSION}
RUN echo GARFIELD_VERSION: ${GARFIELD_VERSION}

ARG APPS_DIR=/usr/local

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && \
    apt-get install -y \
    apt-utils binutils build-essential ca-certificates cmake wget curl davix-dev dcap-dev dpkg-dev fonts-freefont-ttf g++ gcc gfortran \
    git libafterimage-dev libcfitsio-dev libexpat-dev libfcgi-dev libfftw3-dev libfreetype6-dev libftgl-dev libgfal2-dev libgif-dev \
    libgl2ps-dev libglew-dev libglu-dev libgraphviz-dev libgsl-dev libjpeg-dev liblz4-dev liblzma-dev libmpc-dev libmysqlclient-dev  \
    libpcre++-dev libpng-dev libpq-dev libpythia8-dev libspdlog-dev libsqlite3-dev libssl-dev libtbb-dev libtiff-dev libx11-dev \
    libxerces-c-dev libxext-dev libxft-dev libxml2-dev libxmu-dev libxpm-dev libxxhash-dev libz-dev libzstd-dev locales make openssl \
    python3-dev python3-pip ntp qt5-default software-properties-common srm-ifce-dev unixodbc-dev \
    libpq-dev postgresql-server-dev-all libboost-all-dev && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/cache/apt/archives/* && \
    rm -rf /var/lib/apt/lists/*

# ROOT
RUN git clone https://github.com/root-project/root.git $APPS_DIR/root/source && \
    cd $APPS_DIR/root/source && git reset --hard ${ROOT_VERSION} && \
    mkdir -p $APPS_DIR/root/build &&  cd $APPS_DIR/root/build && \
    cmake $APPS_DIR/root/source -DCMAKE_INSTALL_PREFIX=$APPS_DIR/root/install -DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD -Dgdml=ON -Dbuiltin_afterimage=ON && \
    make -j$(nproc) install && \
    rm -rf $APPS_DIR/root/build $APPS_DIR/root/source

ENV ROOTSYS $APPS_DIR/root/install
ENV PATH $APPS_DIR/root/install/bin:$PATH
ENV LD_LIBRARY_PATH $APPS_DIR/root/install/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH $APPS_DIR/root/install/lib:$PYTHONPATH

# GARFIELD
RUN git clone https://gitlab.cern.ch/garfield/garfieldpp.git $APPS_DIR/garfieldpp/source && \
    cd $APPS_DIR/garfieldpp/source && git reset --hard ${GARFIELD_VERSION} && \
    mkdir -p $APPS_DIR/garfieldpp/build &&  cd $APPS_DIR/garfieldpp/build && \
    cmake ../source/ -DCMAKE_INSTALL_PREFIX=$APPS_DIR/garfieldpp/install \
    -DWITH_EXAMPLES=OFF -DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD && \
    make -j$(nproc) install && \
    rm -rf $APPS_DIR/garfieldpp/build $APPS_DIR/garfieldpp/source

ENV LD_LIBRARY_PATH $APPS_DIR/garfieldpp/install/lib:$LD_LIBRARY_PATH
ENV GARFIELD_INSTALL $APPS_DIR/garfieldpp/install
ENV ROOT_INCLUDE_PATH $APPS_DIR/garfieldpp/install/include
ENV HEED_DATABASE $APPS_DIR/garfieldpp/install/share/Heed/database

# GEANT4
RUN git clone https://github.com/Geant4/geant4.git $APPS_DIR/geant4/source && \
    cd $APPS_DIR/geant4/source && git reset --hard ${GEANT4_VERSION} && \
    mkdir -p $APPS_DIR/geant4/build &&  cd $APPS_DIR/geant4/build && \
    cmake ../source/ -DCMAKE_INSTALL_PREFIX=$APPS_DIR/geant4/install -DCMAKE_CXX_STANDARD=$CMAKE_CXX_STANDARD -DGEANT4_BUILD_CXXSTD=$CMAKE_CXX_STANDARD \
    -DGEANT4_BUILD_MULTITHREADED=ON -DGEANT4_USE_QT=ON -DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_RAYTRACER_X11=ON \
    -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML=ON && \
    make -j$(nproc) install && \
    rm -rf $APPS_DIR/geant4/build $APPS_DIR/geant4/source

ENV PATH $APPS_DIR/geant4/install/bin:$PATH
ENV LD_LIBRARY_PATH $APPS_DIR/geant4/install/lib:$LD_LIBRARY_PATH

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
