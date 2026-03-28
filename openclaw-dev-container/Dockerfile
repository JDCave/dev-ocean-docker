# Dockerfile
FROM ghcr.io/openclaw/openclaw:latest

LABEL maintainer="maintainer@example.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
# Development environment variables
ENV EDITOR=vim
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8


# sudo Root
USER root

# Use Aliyun mirrors
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources || \
        sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt-get -qq update && \
        apt-get -qq -y install gnupg ca-certificates curl wget git unzip tar vim build-essential software-properties-common && \
        rm -rf /var/lib/apt/lists/*

# ======================
# Install OpenJDK 25 (LTS)
# ======================
RUN curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list
RUN apt-get -qq update && \
        apt-get -qq -y install zulu25-jdk
RUN apt-get -qq -y autoremove && \
        apt-get -qq -y clean && \
        rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/zulu25-ca-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"


# ======================
# Install Maven 3.9.14
# ======================
ENV MAVEN_VERSION=3.9.14
ENV MAVEN_HOME=/usr/share/maven
RUN wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -O /tmp/maven.tar.gz \
        && mkdir -p $MAVEN_HOME \
        && tar -xzf /tmp/maven.tar.gz -C $MAVEN_HOME --strip-components=1 \
        && rm -f /tmp/maven.tar.gz
ENV PATH="$MAVEN_HOME/bin:${PATH}"

# Configure Maven
RUN mkdir -p /root/.m2
RUN mkdir -p /root/.m2/repository
COPY settings.xml /root/.m2/settings.xml


# ======================
# Install Python
# ======================
RUN apt-get update && \
        apt-get install -y python3 python3-pip && \
        rm -rf /var/lib/apt/lists/*
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
        ln -sf /usr/bin/pip3 /usr/bin/pip
ENV PATH="$PATH:/usr/bin"


# ======================
# Install Node 24.x
# ======================
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
        apt install -y nodejs && \
        apt clean && rm -rf /var/lib/apt/lists/*


# ======================
# Install Rust
# ======================
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"


# ======================
# Install Go
# ======================
ENV GO_VERSION=1.26.1
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz \
        && tar -C /usr/local -xzf /tmp/go.tar.gz \
        && rm -f /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"


# ======================
# Set Metadata & Labels (Build Args for versioning)
# ======================
ARG BUILD_DATE
ARG VERSION
ARG REVISION

LABEL org.opencontainers.image.title="OpenClaw Dev Container"
LABEL org.opencontainers.image.description="Development environment for OpenClaw with auto-configuration"
LABEL org.opencontainers.image.vendor="OpenClaw Team"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${REVISION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"


# ======================
# Verify Installations
# ======================
RUN git --version && \
        curl --version && \
        wget --version && \
        java -version && \
        javac -version && \
        mvn -version && \
        python --version && \
        go version && \
        pip --version && \
        node -v && \
        npm -v && \
        rustc --version && \
        cargo --version


# Set default work directory
WORKDIR /workspace

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
# Convert line endings from Windows (CRLF) to Linux (LF)
RUN sed -i 's/\r$//' /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose gateway port
EXPOSE 18789

# Use entrypoint to auto-configure and start
ENTRYPOINT ["/entrypoint.sh"]
CMD ["gateway"]
