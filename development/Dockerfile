ARG CMAKE_CXX_STANDARD
ARG ROOT_VERSION
ARG GEANT4_VERSION

FROM ghcr.io/lobis/root-geant4-garfield:cxx${CMAKE_CXX_STANDARD}_ROOT${ROOT_VERSION}_Geant4${GEANT4_VERSION}

LABEL maintainer.name="Luis Obis"
LABEL maintainer.email="luis.antonio.obis@gmail.com"

ARG PASSWORD="password"
ARG SSH_PUBLIC_KEY=""

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata

RUN apt-get update \
    && apt-get install -y sudo ssh xauth xorg build-essential gcc g++ gdb clang cmake rsync tar python nano x11-apps nodejs screen \
    && apt-get upgrade -y && apt-get clean

# Jupyter
RUN pip3 -q install pip --upgrade && \
    pip3 list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 pip3 -q install && \
    pip3 -q install uproot awkward matplotlib scipy pandas mplhep boost_histogram \
    numba==0.53 jupyterlab jupyterlab_code_formatter black isort autopep8

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

CMD ["/usr/sbin/sshd", "-D", "-e"]