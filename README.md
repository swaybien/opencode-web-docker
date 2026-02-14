# OpenCode Web Docker

> 简体中文 | [English](README.en.md)

Docker 化的 OpenCode Web 服务器，支持自动构建与部署至 GitHub Container Registry。

## 特性

- **多阶段构建**：基于 Node.js 官方镜像，集成 OpenCode、Rust 工具链与 x‑cmd
- **生产就绪**：使用 `tini` 作为 init 进程，`gosu` 降权运行，支持持久化数据卷
- **灵活配置**：全部 OpenCode Web 服务器选项均可通过环境变量调节
- **CI/CD 自动化**：GitHub Actions 自动构建并推送镜像至 GHCR
- **网络优化**：可选 `chsrc` 镜像源加速（适用于中国网络环境）
- **服务发现**：支持 mDNS 多播 DNS，便于本地网络自动发现

## 快速开始

### 前提条件

- Docker 与 Docker Compose
- OpenCode API 密钥（至少一个模型提供商的 API 密钥）

### 运行

1. 复制环境变量示例文件并编辑：

   ```bash
   cp .env.example .env
   # 编辑 .env，填入你的 API 密钥和其他配置
   ```

2. 启动容器：

   ```bash
   docker-compose up -d
   ```

3. 访问 OpenCode Web 界面：

   ```
   http://localhost:4096
   ```

### 构建本地镜像

```bash
docker build -t opencode-web .
```

## 配置

所有配置均通过环境变量进行。主要变量如下：

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `OPENCODE_API_KEY` | OpenCode 官方 API 密钥 | 必填 |
| `ANTHROPIC_API_KEY` | Anthropic Claude API 密钥 | 可选 |
| `OPENAI_API_KEY` | OpenAI API 密钥 | 可选 |
| `DEEPSEEK_API_KEY` | DeepSeek API 密钥 | 可选 |
| `OPENCODE_SERVER_PORT` | 容器内监听端口 | `4096` |
| `OPENCODE_SERVER_HOST_PORT` | 主机映射端口 | `4096` |
| `OPENCODE_SERVER_HOSTNAME` | 绑定地址 | `0.0.0.0` |
| `OPENCODE_SERVER_USERNAME` | HTTP 基本认证用户名 | 空 |
| `OPENCODE_SERVER_PASSWORD` | HTTP 基本认证密码 | 空 |
| `OPENCODE_SERVER_MDNS` | 启用 mDNS 服务发现 | `false` |
| `DISABLE_CHSRC` | 禁用 chsrc 镜像源加速 | `false` |

完整变量列表参见 [.env.example](.env.example)。

## 持久化数据

容器将 `/root` 目录挂载到 `opencode-web-data` 卷，确保用户数据、配置和模型缓存得以保留。

## CI/CD

项目包含 GitHub Actions 工作流（[.github/workflows/docker.yml](.github/workflows/docker.yml)），在以下情况自动触发：

- 推送至 `master` 分支
- 手动触发（支持自定义标签与是否推送 `latest` 标签）

镜像将推送至 `ghcr.io/swaybien/opencode-web-docker`。

### 手动触发构建

```bash
gh workflow run "Build and Push Docker Image to GHCR"
```

## 许可证

MIT License. 详见 [LICENSE](LICENSE)。

## 致谢

- [OpenCode](https://opencode.ai) – AI 辅助开发平台
- [opencode-docker](https://github.com/utek/opencode-docker) - 原型提供与技术支持
- [chsrc](https://gitee.com/RubyMetric/chsrc) – 镜像源切换工具
- [x‑cmd](https://x-cmd.com) – 现代化的命令行工具集
