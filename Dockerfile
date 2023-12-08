FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/minimal:v1.3

# Install curl, wget, zip, vim, kubectl & desktop dependencies
USER root

COPY setup/ /root/setup

# Add Mozilla Firefox PPA
RUN mkdir -pm755 /etc/apt/preferences.d \
 && echo $'Package: firefox*\nPin: version 1:1snap*\nPin-Priority: -1' > /etc/apt/preferences.d/firefox-nosnap \
 && mkdir -pm755 /etc/apt/trusted.gpg.d && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x0AB215679C571D1C8325275B9BDB3D89CE49EC21" | gpg --dearmor -o /etc/apt/trusted.gpg.d/mozillateam-ubuntu-ppa.gpg \
 && mkdir -pm755 /etc/apt/sources.list.d && echo "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu $(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2) main" > "/etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2).list"

RUN apt-get -y update \
 && apt-get install -y \
    curl \
    wget \
    zip \
    vim \
    icedtea-netx \
    libgl1-mesa-glx \
    libu2f-udev \
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
 && rm -rf /root/setup \
 && apt clean && rm -rf /var/lib/apt/lists/* \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

WORKDIR /opt

# Install Google Chrome
RUN curl -O "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" \
 && dpkg -i google-chrome-stable_current_amd64.deb || true \
 && apt-get install -y -f \
 && rm /opt/google-chrome-stable_current_amd64.deb

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

# Install Jupyter Desktop
RUN sudo /opt/conda/bin/conda install -y -q -c manics websockify
RUN pip install jupyter-remote-desktop-proxy
