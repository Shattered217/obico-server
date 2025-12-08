# Obico ML API for NVIDIA Jetson Orin (JetPack 6)

[English](./Jetson-README.md) | [中文](#chinese)

<a name="chinese"></a>

## 简介

本项目是 Obico (前身 The Spaghetti Detective) 机器学习 API 的移植版本，专为运行 JetPack 6 (Ubuntu 22.04 / CUDA 12.6) 的 NVIDIA Jetson Orin 设备优化。

官方镜像通常基于 x86 或旧版 JetPack (CUDA 10/11)。本项目解决了 CUDA 12.x 和 Ampere 架构的兼容性问题，主要特性包括：

1. **基于 jetson-containers:** 利用 [dusty-nv/jetson-containers](https://github.com/dusty-nv/jetson-containers) 动态构建包含正确 ONNX Runtime 和 OpenCV 依赖的基础镜像。
2. **Darknet 源码编译:** 针对 Orin (compute_87) 编译最新的 Darknet (AlexeyAB) 版本，并修复了 CUDA 12 的链接问题。
3. **一键部署:** 提供自动化脚本，一次性完成环境配置、Docker 运行时设置和镜像构建。

## 环境要求

- **硬件:** NVIDIA Jetson Orin Nano / Orin NX (已测试)
- **系统:** JetPack 6.x (L4T 36.x), Ubuntu 22.04
- **依赖:** `git`, `docker` (脚本会自动处理 nvidia-container-runtime 的配置)

## 安装步骤

### 1. 克隆仓库

```bash
git clone https://github.com/Shattered217/obico-server.git
cd obico-server/ml_api
```

### 2. 一键构建

````

### 2. 一键构建

运行构建脚本。该脚本会执行以下操作：

- 克隆 jetson-containers
- 配置 Docker daemon.json 以支持 NVIDIA runtime
- 构建基础环境（OpenCV, ONNX Runtime）
- 下载模型权重文件（如果本地缺失）
- 编译最终的应用镜像

```bash
chmod +x build.sh run.sh
./build.sh
````

**注意:** 首次构建可能需要较长时间（15-30 分钟），因为涉及 OpenCV 和 Darknet 的源码编译。

### 3. 启动服务

以无头模式（后台）启动容器：

```bash
./run.sh
```

该脚本会自动：

- 清理旧容器
- 释放被占用的 3333 端口
- 使用 Host 网络模式启动容器（确保能访问局域网内的 Home Assistant 等服务）

## 配置说明

您可以修改 `run.sh` 中的环境变量：

- **ML_API_TOKEN:** API 鉴权 Token (默认: `bambu_nb`)

## 致谢

- **Obico:** [TheSpaghettiDetective/obico-server](https://github.com/TheSpaghettiDetective/obico-server)
- **Jetson Containers:** [dusty-nv/jetson-containers](https://github.com/dusty-nv/jetson-containers)
- **Darknet:** [AlexeyAB/darknet](https://github.com/AlexeyAB/darknet)
