# OpenCode Web Docker

> [简体中文](README.md) | English

Dockerized OpenCode web server with automated CI/CD to GitHub Container Registry.

## Features

- **Multi‑stage build**: Based on official Node.js image, integrates OpenCode, Rust toolchain, and x‑cmd
- **Production‑ready**: Uses `tini` as init process, `gosu` for privilege dropping, persistent data volume support
- **Flexible configuration**: All OpenCode web server options configurable via environment variables
- **CI/CD automation**: GitHub Actions automatically builds and pushes image to GHCR
- **Network optimization**: Optional `chsrc` mirror acceleration (useful for network environment in China)
- **Service discovery**: mDNS multicast DNS support for automatic local network discovery

## Quick Start

### Prerequisites

- Docker and Docker Compose
- OpenCode API key (at least one model provider API key)

### Running

1. Copy the environment example file and edit:

   ```bash
   cp .env.example .env
   # Edit .env with your API keys and other configuration
   ```

2. Start the container:

   ```bash
   docker-compose up -d
   ```

3. Access the OpenCode web interface:

   ```
   http://localhost:4096
   ```

### Build Local Image

```bash
docker build -t opencode-web .
```

## Configuration

All configuration is done via environment variables. Key variables are:

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENCODE_API_KEY` | OpenCode official API key | Required |
| `ANTHROPIC_API_KEY` | Anthropic Claude API key | Optional |
| `OPENAI_API_KEY` | OpenAI API key | Optional |
| `DEEPSEEK_API_KEY` | DeepSeek API key | Optional |
| `OPENCODE_SERVER_PORT` | Container listening port | `4096` |
| `OPENCODE_SERVER_HOST_PORT` | Host mapped port | `4096` |
| `OPENCODE_SERVER_HOSTNAME` | Bind address | `0.0.0.0` |
| `OPENCODE_SERVER_USERNAME` | HTTP basic auth username | Empty |
| `OPENCODE_SERVER_PASSWORD` | HTTP basic auth password | Empty |
| `OPENCODE_SERVER_MDNS` | Enable mDNS service discovery | `false` |
| `DISABLE_CHSRC` | Disable chsrc mirror acceleration | `false` |

For the complete variable list, see [.env.example](.env.example).

## Persistent Data

The container mounts `/root` to `opencode-web-data` volume, preserving user data, configuration, and model cache.

## CI/CD

The project includes a GitHub Actions workflow ([.github/workflows/docker.yml](.github/workflows/docker.yml)) triggered automatically on:

- Push to the `master` branch
- Manual dispatch (supports custom tags and optional `latest` tag push)

Images are pushed to `ghcr.io/swaybien/opencode-web-docker`.

### Manually Trigger Build

```bash
gh workflow run "Build and Push Docker Image to GHCR"
```

## License

MIT License. See [LICENSE](LICENSE).

## Acknowledgements

- [OpenCode](https://opencode.ai) – AI‑assisted development platform
- [opencode-docker](https://github.com/utek/opencode-docker) - Reference and tech support
- [chsrc](https://gitee.com/RubyMetric/chsrc) – Mirror source switcher
- [x‑cmd](https://x-cmd.com) – Modern command‑line toolset
