# ML API (Jetson)

## English

- Prereqs: Docker with NVIDIA Container Toolkit, internet access to pull base layers.
- Build images from `ml_api` root: `bash scripts/build_jetson.sh` (runs `Dockerfile.base_arm64` then `Dockerfile`).
- Run container: `bash scripts/run_jetson.sh` (defaults `ML_API_TOKEN=bambu_nb`, override by exporting `ML_API_TOKEN`).
- Container exposes `3333` on host via `--network host`; adjust port mapping in the script if needed.

## 中文

- 前置条件：已安装 Docker 和 NVIDIA Container Toolkit，可联网拉取镜像层。
- 在 `ml_api` 目录构建镜像：`bash scripts/build_jetson.sh`（依次构建 `Dockerfile.base_arm64` 与 `Dockerfile`）。
- 运行容器：`bash scripts/run_jetson.sh`（默认 `ML_API_TOKEN=bambu_nb`，可通过环境变量覆盖）。
- 容器使用 `--network host` 暴露 `3333` 端口，如需修改请调整脚本中的端口映射。
