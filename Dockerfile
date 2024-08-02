ARG BASE_IMAGE=quay.io/jupyter/minimal-notebook:2024-07-29

FROM ${BASE_IMAGE}

# Switch to root for linux updates and installs
USER root

COPY setup/ /root/setup

# Install rclone and kubectl
RUN install -o root -g root -m 0755 /root/setup/kubectl /usr/local/bin/kubectl \
 && chmod +x /root/setup/install-rclone.sh \
 && bash /root/setup/install-rclone.sh \
 && rm -rf /root/setup

# Install Jupyter Desktop Dependencies, zip and vim
RUN apt-get -y update \
 && apt-get -y install \
    dbus-x11 \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
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
RUN /opt/conda/bin/conda install -y -q -c manics websockify
RUN pip install jupyter-remote-desktop-proxy
