# Image args:
#
# GITHUB_SCOPE      GitHub org name or user/repo name.
# GITHUB_TOKEN      PAT with [admin, repo, workflow] scope (/admin/admin:org/ for orgs)
# GITHUB_DOMAIN     (Optional) Server hostname. Defaults to "github.com"
# GITHUB_API_V3     (Optional) https://${GITHUB_DOMAIN}/api/v3. Defaults to https://api.github.com
# GITHUB_RUNNER     (Optional) Specific version for the runner, e.g. "2.274.1"

FROM ubuntu:20.04 as base

ARG GITHUB_RUNNER=2.274.1

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG en_US.UTF-8
ENV TERM xterm-256color

RUN  apt-get update -y \
  && apt-get install -y \
    bash \
    bison \
    brotli \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    dbus \
    dnsutils \
    dpkg \
    fakeroot \
    file \
    flex \
    fontconfig \
    ftp \
    git \
    gnupg2 \
    graphviz \
    gsfonts \
    iproute2 \
    iptables \
    iputils-ping \
    jq \
    lib32z1 \
    libc++-dev \
    libc++abi-dev \
    libcurl4 \
    libfreetype-dev \
    libgbm-dev \
    libgconf-2-4 \
    libgd-dev \
    libgtk-3-0 \
    libncurses-dev \
    libreadline-dev \
    libsecret-1-dev \
    libsqlite3-dev \
    libunwind8 \
    libxkbfile-dev \
    libxss1 \
    locales \
    m4 \
    make \
    netcat \
    openssh-client \
    parallel \
    patchelf \
    pkg-config \
    python-is-python3 \
    rpm \
    rsync \
    shellcheck \
    sqlite3 \
    ssh \
    sudo \
    sudo \
    telnet \
    texinfo \
    time \
    tk \
    ttf-dejavu \
    tzdata \
    uidmap \
    unzip \
    unzip \
    upx \
    wget \
    wget \
    xorriso \
    xvfb \
    xz-utils \
    zip \
    zstd \
    zsync \
  && update-ca-certificates \
  && rm -rf /var/lib/apt/lists/*
SHELL ["/bin/bash", "-c"]

# Create a default user and add it to sudoers
RUN useradd -m -r -g users actions
RUN echo "actions ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install rootless docker (Doesn't work yet)
#RUN  echo "actions:100000:65536" >> /etc/subuid \
#  && echo "actions:100000:65536" >> /etc/subgid \
#  && groupadd docker \
#  && usermod -aG docker actions \
#  && newgrp docker
#RUN set -o pipefail \
#  && curl -fsSL https://get.docker.com/rootless | DOCKER_BIN=/opt/docker-rootless sh
#ENV PATH="/opt/docker-rootless:$PATH"

# Install a few JDKs from Azul, making Java 11 (LTS) the default
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN curl -fsSLO https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb \
  && apt-get install -y ./zulu-repo_1.0.0-2_all.deb \
  && rm ./zulu-repo_1.0.0-2_all.deb \
  && apt-get update -y \
  && apt-get install -y \
    zulu8-jdk \
    zulu11-jdk \
    zulu13-jdk \
    zulu15-jdk \
  && rm -rf /var/lib/apt/lists/* \
  && update-java-alternatives -s zulu11-ca-amd64 \
  && ln -s /usr/lib/jvm/zulu11 /usr/lib/jvm/default

ENV JAVA_HOME=/usr/lib/jvm/default
ENV JAVA8_HOME=/usr/lib/jvm/zulu8
ENV JAVA11_HOME=/usr/lib/jvm/zulu11
ENV JAVA13_HOME=/usr/lib/jvm/zulu13
ENV JAVA15_HOME=/usr/lib/jvm/zulu15

# Install GitHub runner
USER actions
WORKDIR /home/actions/github-runner
RUN set -o pipefail \
  && curl -fsSL https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER}/actions-runner-linux-x64-${GITHUB_RUNNER}.tar.gz \
     | tar xzp
USER root
RUN bin/installdependencies.sh

# Install Android SDK
USER actions
WORKDIR /home/actions/android
RUN set -o pipefail \
  && curl -fsSLo tools.zip https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip \
  && unzip tools.zip \
  && rm -f tools.zip
RUN yes | cmdline-tools/bin/sdkmanager --sdk_root=. --licenses
# See https://github.com/actions/virtual-environments/blob/main/images/linux/Ubuntu2004-README.md#android
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'extras;android;m2repository'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'extras;google;m2repository'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'platform-tools'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'patcher;v4'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;29.0.0'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;29.0.1'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;29.0.2'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;29.0.3'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;30.0.0'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;30.0.1'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'build-tools;30.0.2'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'cmake;3.10.2.4988404'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'ndk-bundle'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'platforms;android-27'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'platforms;android-28'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'platforms;android-29'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'platforms;android-30'
RUN cmdline-tools/bin/sdkmanager --sdk_root=. 'extras;google;google_play_services'
ENV ANDROID_HOME=/home/actions/android
ENV ANDROID_SDK_ROOT=/home/actions/android
ENV PATH="$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools/bin:$PATH"

# -------------------------------------------------------------
# Configure container
FROM base as configure
ARG GITHUB_SCOPE
ARG GITHUB_REGISTRATION_TOKEN
ARG GITHUB_DOMAIN=github.com

USER actions
WORKDIR /home/actions/github-runner
COPY scripts/get-runner-registration-token.sh .
RUN set -o pipefail \
  && ./config.sh \
      --unattended \
      --replace \
      --name 'onprem-ubuntu-2004' \
      --url "https://$GITHUB_DOMAIN/$GITHUB_SCOPE" \
      --token "$(./get-runner-registration-token.sh "$GITHUB_DOMAIN" "$GITHUB_SCOPE")"
ENTRYPOINT [ "/bin/bash", "-l", "-c"]
CMD [ "run.sh" ]
