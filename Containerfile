FROM quay.io/toolbx-images/alpine-toolbox:edge AS alpine-boxkit-base

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="A cloud-native terminal experience" \
      maintainer="johnr14"

COPY extra-packages.alpine /
RUN apk update && \
    apk upgrade && \
    grep -v '^#' /extra-packages.alpine | xargs apk add
RUN rm /extra-packages.alpine

RUN   ln -fs /bin/sh /usr/bin/sh && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update
     

FROM quay.io/fedora/fedora-toolbox:40 AS fedora-boxkit-base
# Support Nvidia Container Runtime (https://developer.nvidia.com/nvidia-container-runtime)
#ENV NVIDIA_VISIBLE_DEVICES all
#ENV NVIDIA_DRIVER_CAPABILITIES all

ARG IMAGE_NAME="${IMAGE_NAME:-fedora-boxkit-base}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-fedora-toolbox}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox commands" \
      summary="Dependencies for running DaVinci Resolve on image-based Linux operating systems" \
      maintainer="johnr14"

#COPY system_files /

# Bundle everything in one command will it reduce the number of layers ?
COPY extra-packages.fedora /
RUN dnf -y update && \
    dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm && \
    dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    grep -v '^#' /extra-packages.fedora | xargs dnf -y install && \
    rm /extra-packages.fedora && \
    dnf clean all
