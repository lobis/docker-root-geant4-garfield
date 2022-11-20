ARG CMAKE_CXX_STANDARD
ARG ROOT_VERSION
ARG GEANT4_VERSION
ARG GARFIELD_VERSION

FROM ghcr.io/lobis/root-geant4-garfield:cpp${CMAKE_CXX_STANDARD}_ROOT-${ROOT_VERSION}_Geant4-${GEANT4_VERSION}_Garfield-${GARFIELD_VERSION}

ARG PASSWORD="password"
ARG SSH_PUBLIC_KEY=""

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata

RUN apt-get update \
    && apt-get install -y sudo ssh xauth xorg build-essential gcc g++ gdb clang cmake rsync tar nano x11-apps nodejs screen tmux vim zsh curl \
    && apt-get upgrade -y && apt-get clean

# ROOT
# change default GUI port to a fixed one instead of a range
RUN sed -i "/WebGui.HttpPort:/c\WebGui.HttpPort:            9000" $ROOTSYS/etc/root/system.rootrc

# Jupyter
RUN python -m pip -q install pip --upgrade && \
    python -m pip --disable-pip-version-check list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" && \
    python -m pip -q install uproot awkward metakernel matplotlib scipy pandas mplhep boost_histogram ipympl \
    numba jupyterlab black isort autopep8 jupyterlab_code_formatter aquirdturtle_collapsible_headings pre-commit

RUN mkdir -p /root/Notebooks
RUN echo "alias start-jupyter='cd /root/Notebooks && jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser'" >> /root/.bashrc

# SSH settings
RUN ( \
    echo "LogLevel DEBUG2"; \
    echo "PermitRootLogin yes"; \
    echo "X11Forwarding yes"; \
    echo "X11UseLocalhost no"; \
    echo "PasswordAuthentication yes"; \
    echo "Port 22"; \
    echo "Protocol 2"; \
    echo "AddressFamily inet"; \
    echo "Subsystem sftp /usr/lib/openssh/sftp-server"; \
    ) > /etc/ssh/sshd_config \
    && mkdir /run/sshd

RUN mkdir -p /root/.ssh
RUN echo ${SSH_PUBLIC_KEY} >> /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

RUN yes ${PASSWORD} | passwd

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

WORKDIR /

# ssh
EXPOSE 22
# jupyter
EXPOSE 8888
# ROOT web gui
EXPOSE 9000

CMD ["/usr/sbin/sshd", "-D", "-e"]
