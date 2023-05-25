FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/minimal:latest

USER root

COPY setup/ /root/setup

RUN apt-get -y update \
    && apt-get install -y curl wget zip vim \
    && install -o root -g root -m 0755 /root/setup/kubectl /usr/local/bin/kubectl \
    && chmod +x /root/setup/install-rclone.sh \
    && bash /root/setup/install-rclone.sh \
    && rm -rf /root/setup

USER $NB_USER