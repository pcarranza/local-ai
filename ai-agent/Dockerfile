FROM alpine

# https://opencode.ai/docs/cli/#environment-variables
ENV OPENCODE_CONFIG_DIR=/workspace/.config/opencode/

ENV PATH="/opt/bun/bin:/opt/opencode/bin:${PATH}"

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
    g++ \
    && curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.3" \
    && mv /root/.bun /opt/bun && ln -s /opt/bun /root/.bun

COPY startup.sh /usr/local/bin/startup.sh

RUN curl -fsSL https://opencode.ai/install | bash \
    && mv /root/.opencode /opt/opencode && ln -s /opt/opencode /root/.opencode \
    && curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash \
    && chmod +x /usr/local/bin/startup.sh

USER 1000:1000

WORKDIR /workspace

ENV GOPATH=/workspace/go

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/startup.sh"]
