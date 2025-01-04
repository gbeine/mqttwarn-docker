# Docker build file for `mqttwarn-standard`.
#
# Invoke like:
#
#   docker build --tag=local/mqttwarn-standard --file=Dockerfile .
#
FROM python:3.11-slim-bullseye


# =====
# Build
# =====

# Install build prerequisites.
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN \
    true \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --yes git

# Create /etc/mqttwarn
RUN mkdir -p /etc/mqttwarn
WORKDIR /etc/mqttwarn

# Add user "mqttwarn"
RUN groupadd -r mqttwarn && useradd -r -g mqttwarn mqttwarn
RUN chown -R mqttwarn:mqttwarn /etc/mqttwarn

# Install package.
COPY mqttwarn /src
RUN \
    true \
    && pip install --upgrade pip \
    && pip install --prefer-binary versioningit wheel \
    && pip install --use-pep517 --prefer-binary '/src'

# Uninstall build prerequisites again.
RUN apt-get --yes remove --purge git && apt-get --yes autoremove

# Purge /src and /tmp directories.
RUN rm -rf /src /tmp/*


# =======
# Runtime
# =======

# Make process run as "mqttwarn" user
USER mqttwarn

# Use configuration file from host
VOLUME ["/etc/mqttwarn"]

# Set default configuration path
ENV MQTTWARNINI="/etc/mqttwarn/mqttwarn.ini"

# Invoke program
CMD mqttwarn
