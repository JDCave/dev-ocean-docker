# ===========================================================================
# Hermes Agent Development Container
# ===========================================================================
# Based on the official Hermes Agent Dockerfile, augmented with a full
# development toolchain (Java 25, Maven 3.9.15, Node 24, Rust, Go 1.26.1).
#
# Build with HERMES_SOURCE_PATH env var (docker-compose will pass it):
#   cd hermes-dev-container && docker-compose build
# ===========================================================================

# ---------- Stage 1: uv (Python package manager) ----------
FROM ghcr.io/astral-sh/uv:0.11.6-python3.13-trixie@sha256:b3c543b6c4f23a5f2df22866bd7857e5d304b67a564f4feab6ac22044dde719b AS uv_source

# ---------- Stage 2: gosu (privilege dropping helper) ----------
# Use docker.1ms.run mirror to bypass broken docker.m.daocloud.io daemon mirror
FROM docker.1ms.run/tianon/gosu:1.19-trixie@sha256:3b176695959c71e123eb390d427efc665eeb561b1540e82679c15e992006b8b9 AS gosu_source

# ---------- Stage 3: Main build ----------
FROM docker.1ms.run/library/debian:13.4

LABEL maintainer="magical_kingdom@126.com"
LABEL org.opencontainers.image.title="Hermes Agent Dev Container"
LABEL org.opencontainers.image.description="Hermes Agent with full development toolchain"

# Disable Python stdout buffering
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
# Playwright browsers outside the volume mount
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/hermes/.playwright

# ---------- Tsinghua mirror (Tuna) ----------
# deb.debian.org is unreliable from China; Tuna mirrors Debian Trixie reliably.
RUN sed -i 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/debian.sources || \
        sed -i 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list

# ---------- System dependencies ----------
# Official Hermes deps + dev tool prerequisites in one layer.
# tini reaps orphaned zombie processes (MCP stdio subprocesses, git, bun, etc.)
RUN apt-get update && \
        apt-get install -y --no-install-recommends \
                build-essential nodejs npm python3 ripgrep ffmpeg gcc python3-dev \
                libffi-dev procps git openssh-client docker-cli tini \
                gnupg ca-certificates curl wget unzip tar vim && \
        rm -rf /var/lib/apt/lists/*

# ---------- Hermes user ----------
# Non-root user for runtime; UID can be overridden via HERMES_UID at runtime
RUN useradd -u 10000 -m -d /opt/data hermes

# ---------- Copy binary tools from multi-stage sources ----------
COPY --chmod=0755 --from=gosu_source /gosu /usr/local/bin/
COPY --chmod=0755 --from=uv_source /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/

WORKDIR /opt/hermes

# ---------- Layer-cached npm dependency install ----------
# Copy only package manifests first so npm install + Playwright are cached
# unless the lockfiles themselves change.
COPY package.json package-lock.json ./
COPY web/package.json web/package-lock.json web/

RUN npm install --prefer-offline --no-audit && \
        npx playwright install --with-deps chromium --only-shell && \
        (cd web && npm install --prefer-offline --no-audit) && \
        npm cache clean --force

# ---------- Source code ----------
# .dockerignore excludes node_modules, so the installs above survive.
COPY --chown=hermes:hermes . .

# Fix CRLF line endings from Windows host
RUN sed -i 's/\r$//' docker/entrypoint.sh

# Build web dashboard (Vite outputs to hermes_cli/web_dist/)
RUN cd web && npm run build


# ===========================================================================
# Development Toolchain
# ===========================================================================

# ---------- Java 25 (Azul Zulu JDK) ----------
RUN curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | \
                tee /etc/apt/sources.list.d/zulu.list && \
        apt-get -qq update && \
        apt-get -qq -y install zulu25-jdk && \
        apt-get -qq -y autoremove && \
        apt-get -qq -y clean && \
        rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/zulu25-ca-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

# ---------- Maven 3.9.15 ----------
ENV MAVEN_VERSION=3.9.15
ENV MAVEN_HOME=/usr/share/maven
RUN wget -q https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
                -O /tmp/maven.tar.gz && \
        mkdir -p $MAVEN_HOME && \
        tar -xzf /tmp/maven.tar.gz -C $MAVEN_HOME --strip-components=1 && \
        rm -f /tmp/maven.tar.gz
ENV PATH="$MAVEN_HOME/bin:${PATH}"

# Maven settings.xml with Aliyun mirrors (embedded inline — outside build context)
RUN mkdir -p /root/.m2/repository && \
        cat > /root/.m2/settings.xml << 'MAVEN_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">

  <localRepository>/root/.m2/repository</localRepository>
  <interactiveMode>true</interactiveMode>
  <offline>false</offline>

  <mirrors>
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
    <mirror>
      <id>jboss-public-repository-group</id>
      <mirrorOf>*</mirrorOf>
      <name>JBoss Public Repository Group</name>
      <url>http://repository.jboss.org/nexus/content/groups/public</url>
    </mirror>
    <mirror>
      <id>ibiblio</id>
      <mirrorOf>*</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>https://maven.aliyun.com/mvn/view</url>
    </mirror>
    <mirror>
      <id>central</id>
      <name>Maven Repository Switchboard</name>
      <url>http://repo1.maven.org/maven2/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
    <mirror>
      <id>repo2</id>
      <mirrorOf>*</mirrorOf>
      <name>Human Readable Name for this Mirror.</name>
      <url>http://repo2.maven.org/maven2/</url>
    </mirror>
  </mirrors>

  <profiles>
    <profile>
      <id>boundlessgeo</id>
      <repositories>
        <repository>
          <id>boundlessgeo</id>
          <url>https://repo.boundlessgeo.com/main/</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
          </snapshots>
        </repository>
      </repositories>
    </profile>
    <profile>
      <id>aliyun</id>
      <repositories>
        <repository>
          <id>aliyun</id>
          <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
          </snapshots>
        </repository>
      </repositories>
    </profile>
    <profile>
      <id>maven-central</id>
      <repositories>
        <repository>
          <id>maven-central</id>
          <url>http://central.maven.org/maven2/</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>boundlessgeo</activeProfile>
    <activeProfile>aliyun</activeProfile>
    <activeProfile>maven-central</activeProfile>
  </activeProfiles>
</settings>
MAVEN_EOF

# ---------- Python symlink ----------
RUN ln -sf /usr/bin/python3 /usr/bin/python

# ---------- Node 24.x ----------
# Overrides the system nodejs (Debian 13) with Node 24 from nodesource.
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
        apt-get update && \
        apt-get install -y nodejs && \
        apt-get -qq -y autoremove && \
        apt-get -qq -y clean && \
        rm -rf /var/lib/apt/lists/*

# ---------- Rust ----------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# ---------- Go 1.26.1 ----------
ENV GO_VERSION=1.26.1
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
        tar -C /usr/local -xzf /tmp/go.tar.gz && \
        rm -f /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"


# ===========================================================================
# Permissions & Python virtualenv
# ===========================================================================

# Make install dir world-readable so any HERMES_UID can read it at runtime
USER root
RUN chmod -R a+rX /opt/hermes

# ---------- Python virtualenv (Hermes runtime) ----------
RUN uv venv && \
        uv pip install --no-cache-dir -e ".[all]"

# ---------- Runtime ----------
ENV HERMES_WEB_DIST=/opt/hermes/hermes_cli/web_dist
ENV HERMES_HOME=/opt/data
ENV PATH="/opt/data/.local/bin:${PATH}"

VOLUME [ "/opt/data" ]
ENTRYPOINT [ "/usr/bin/tini", "-g", "--", "/opt/hermes/docker/entrypoint.sh" ]

# ---------- Verify installations ----------
RUN echo "=== Tool Versions ===" && \
        java -version 2>&1 && \
        javac -version 2>&1 && \
        mvn -version && \
        python --version && \
        uv --version && \
        node -v && \
        npm -v && \
        rustc --version && \
        cargo --version && \
        go version && \
        git --version && \
        echo "=== All tools installed successfully ==="
