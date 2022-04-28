ARG CMAKE_CXX_STANDARD
ARG ROOT_VERSION
ARG GEANT4_VERSION
ARG GARFIELD_VERSION

FROM ghcr.io/lobis/root-geant4-garfield-dev:cpp${CMAKE_CXX_STANDARD}_ROOT-${ROOT_VERSION}_Geant4-${GEANT4_VERSION}_Garfield-${GARFIELD_VERSION}

ENV REST_PATH /usr/local/rest-for-physics

RUN git clone https://github.com/rest-for-physics/framework.git /tmp/framework \
    && cd /tmp/framework \
    && python3 pull-submodules.py --clean --force --dontask --latest:master \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=$REST_PATH -DREST_GARFIELD=ON -DREST_G4=ON -DRESTLIB_DETECTOR=ON -DRESTLIB_RAW=ON -DRESTLIB_TRACK=ON -DREST_WELCOME=OFF \
    && make -j$(nproc) install \
    && rm -rf /tmp/framework

ENV PATH $REST_PATH/bin:$PATH
ENV LD_LIBRARY_PATH $REST_PATH/lib:$LD_LIBRARY_PATH

RUN echo "source $REST_PATH/thisREST.sh" >> ~/.bashrc

ENTRYPOINT ["/tini", "--"]

WORKDIR /

# ssh
EXPOSE 22
# jupyter
EXPOSE 8888
# ROOT web gui
EXPOSE 9000

CMD ["/usr/sbin/sshd", "-D", "-e"]
