FROM node:22-slim

# 设置环境变量 | Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖 | Install dependencies
RUN apt update && apt install -y --no-install-recommends curl ca-certificates && update-ca-certificates
RUN curl -LO https://gitee.com/RubyMetric/chsrc/releases/download/pre/chsrc_latest-1_amd64.deb
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && apt install -y --no-install-recommends \
    bash \
    nano \
    chromium \
    wget \
    fonts-liberation \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    gnupg \
    git \
    gosu \
    jq \
    python3 \
    python3-pip \
    build-essential \
    unzip \
    pandoc \
    socat \
    tini \
    websockify \
    gh \
    texlive-base \
    texlive-binaries \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-latex-recommended \
    texlive-lang-chinese \
    texlive-latex-extra \
    nix-setup-systemd \
 && apt install -y ./chsrc_latest-1_amd64.deb \
 && apt autoremove -y \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && usermod -aG nix-users node
RUN rm ./chsrc_latest-1_amd64.deb

# 复制启动脚本 | Copy entrypoint
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置工作目录为 home | Set the working directory to home
WORKDIR /home/node

# 将 opencode 添加到 PATH
ENV PATH="/home/node/.cargo/bin:/home/node/.local/bin:/home/node/.opencode/bin:${PATH}"

# 切换到 node 用户 | Switch to the node user
USER node

# 安装 OpenCode | Install OpenCode from npm
RUN mkdir -p /home/node/.local/share/opencode && chown -R node:node /home/node
RUN curl -fsSL https://opencode.ai/install | bash
RUN test -x /home/node/.opencode/bin/opencode && echo "OpenCode installed successfully" || (echo "OpenCode installation failed" && exit 1)

# 安装 x-cmd | Install x-cmd
RUN eval "$(curl https://get.x-cmd.com)"

# 安装 Rust | Install Rust toolchain
RUN curl -sSf https://sh.rustup.rs --output rustup-init && \
    sh rustup-init -y && \
    rm rustup-init && \
    rustup component add rustfmt clippy

# 复制 nano 配置 | Copy .nanorc
COPY .nanorc /home/node/.nanorc

# 使用 tini 作为 init 进程，运行 entrypoint.sh | User tini as ini to start entrypoint
ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"]
