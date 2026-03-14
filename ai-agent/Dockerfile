FROM alpine

# https://opencode.ai/docs/cli/#environment-variables
ENV OPENCODE_CONFIG_DIR=/workspace/.config/opencode/

ENV PATH="/opt/bun/bin:/opt/opencode/bin:${PATH}"

ARG OPENCODE_VERSION=v1.2.21

ARG BUN_VERSION=bun-v1.3.3

ARG OPENCHAMBER_VERSION=1.8.5

RUN apk --no-cache add \
    ca-certificates \
    curl \
    bash \
    python3 \
    py3-pip \
    git \
    go \
    nodejs \
    make \
    ripgrep \
    libc6-compat \
    g++ \
    && curl -fsSL https://bun.sh/install | bash -s "${BUN_VERSION}" \
    && mv /root/.bun /opt/bun && ln -s /opt/bun /root/.bun

COPY startup.sh /usr/local/bin/startup.sh

RUN curl -fsSL https://opencode.ai/install | bash -s -- --version "${OPENCODE_VERSION}" \
    && mv /root/.opencode /opt/opencode && ln -s /opt/opencode /root/.opencode \
    && bun add -g "@openchamber/web@${OPENCHAMBER_VERSION}" \
    && chmod +x /usr/local/bin/startup.sh

USER 1000:1000

WORKDIR /workspace

ENV GOPATH=/workspace/go

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/startup.sh"]
