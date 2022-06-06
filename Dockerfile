FROM ubuntu:22.04 
USER root
LABEL maintainer="Mattias Ghodsian"
LABEL website="https://github.com/mattiasghodsian/dockerized-vrising-server"
LABEL desc="Dockerized V Rising dedicated server"
VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata"]

ARG DEBIAN_FRONTEND="noninteractive"
RUN apt update -y && \
    apt-get upgrade -y && \
    apt-get install -y  apt-utils && \
    apt-get install -y  software-properties-common && \
    apt-get install -y  cron && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt update -y && \
    apt-get upgrade -y 
RUN useradd -m steam && cd /home/steam && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt purge steam steamcmd && \
    apt install -y gdebi-core  \
                   libgl1-mesa-glx:i386 \
                   wget && \
    apt install -y steam \
                   steamcmd && \
    ln -s /usr/games/steamcmd /usr/bin/steamcmd
#RUN apt install -y mono-complete
RUN apt install -y wine 
RUN apt install -y xserver-xorg \
                   xvfb
RUN rm -rf /var/lib/apt/lists/* && \
    apt clean && \
    apt autoremove -y 

# Copy scripts 
COPY scripts/entrypoint.sh /home/steam/entrypoint.sh
COPY scripts/auto_backup.sh /home/steam/auto_backup.sh

# Set permissions
RUN chmod +x /home/steam/entrypoint.sh && \
    chmod +x /home/steam/auto_backup.sh

ENTRYPOINT ["/home/steam/entrypoint.sh"]