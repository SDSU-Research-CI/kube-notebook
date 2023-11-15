FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/minimal:latest

USER root

COPY setup/ /root/setup

# Install curl, wget, zip, vim, kubectl & desktop dependencies
RUN apt-get -y update \
    && apt-get install -y \
    curl \
    wget \
    zip \
    vim \
    icedtea-netx \
    net-tools \
    dbus-x11 \
    firefox \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    && apt-get remove -y -q light-locker \
    && install -o root -g root -m 0755 /root/setup/kubectl /usr/local/bin/kubectl \
    && chmod +x /root/setup/install-rclone.sh \
    && bash /root/setup/install-rclone.sh \
    && rm -rf /root/setup

USER jovyan

# Install Jupyter Desktop
RUN conda install -y -c manics websockify
RUN pip install jupyter-remote-desktop-proxy