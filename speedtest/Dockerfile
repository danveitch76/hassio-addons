ARG BUILD_FROM
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

FROM ${BUILD_FROM}

ARG BUILD_ARCH

# Setup base
ARG BUILD_ARCH
ARG CLI_VERSION

# Install Offical Speedtest-CLI
RUN \
    cd /tmp &&\
    arch=$(echo $BUILD_ARCH | sed s/armhf/armel/ | sed s/armv7/armhf/ | sed s/amd64/x86_64/ ) && \
    curl https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-${arch}.tgz -o speedtest.tgz &&\
    tar zxvf speedtest.tgz &&\
    mv speedtest /usr/local/bin/ &&\
    rm -rf /tmp/*

# Copy root files and folders
COPY rootfs /

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Dan Veitch <@danveitch76>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Dan Add-ons" \
    org.opencontainers.image.authors="Dan Veitch <@danveitch76>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/danveitch76/hassio-addons" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}