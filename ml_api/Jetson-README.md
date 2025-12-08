# Obico ML API for NVIDIA Jetson Orin (JetPack 6)

[English](#english) | [中文](./Jetson-README-CN.md)

<a name="english"></a>

## Overview

This project is a specialized port of the [Obico (formerly The Spaghetti Detective) Machine Learning API](https://github.com/TheSpaghettiDetective/obico-server), optimized for **NVIDIA Jetson Orin** devices running **JetPack 6 (Ubuntu 22.04 / CUDA 12.6)**.

The official Docker images are often built for x86 or older JetPack versions (CUDA 10/11). This repository solves compatibility issues with CUDA 12.x and the Ampere GPU architecture by:

1.  **Leveraging `jetson-containers`:** Uses [dusty-nv/jetson-containers](https://github.com/dusty-nv/jetson-containers) to dynamically build a base image with correct ONNX Runtime and OpenCV dependencies.
2.  **Custom Darknet Compilation:** Compiles the latest Darknet (AlexeyAB) from source with specific optimizations for Orin (`compute_87`) and CUDA 12 compatibility patches.
3.  **Automated Deployment:** Provides scripts to handle environment setup, Docker runtime configuration, and container building in one go.

## Prerequisites

- **Hardware:** NVIDIA Jetson Orin Nano / Orin NX (tested).
- **System:** JetPack 6.x (L4T 36.x), Ubuntu 22.04.
- **Dependencies:** `git`, `docker` (Scripts will handle `nvidia-container-runtime` setup).

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Shattered217/obico-server.git
cd your-repo-name/ml_api
```

> **Note:** Ensure your directory structure matches the scripts, with `build.sh` inside `ml_api` folder.

### 2. One-Click Build

Run the build script. This script will:

- Clone jetson-containers
- Configure Docker daemon.json for NVIDIA runtime
- Build the base environment (OpenCV, ONNX Runtime)
- Download model weights (if missing)
- Compile the final application image

```bash
chmod +x build.sh run.sh
./build.sh
```

**Note:** This process may take a while (15-30 mins) as it builds OpenCV and Darknet from source.

### 3. Run the Service

Start the container in headless mode (background):

```bash
./run.sh
```

This script handles:

- Cleaning up old containers
- Releasing port 3333 if occupied
- Starting the container with host networking (essential for accessing local instances like Home Assistant)

## Configuration

You can modify `run.sh` to change environment variables:

- **ML_API_TOKEN:** The authentication token for the API (Default: `bambu_nb`)
- **NO_PROXY:** Critical for local network access. Default includes `localhost,127.0.0.1,192.168.101.194`. Update this IP to match your Home Assistant IP if necessary.

## Directory Structure

- `build.sh`: Main deployment script
- `run.sh`: Startup script
- `Dockerfile.app`: The application layer Dockerfile
- `Makefile`: Optimized Darknet configuration for Orin
- `requirements.txt`: Python dependencies

## Troubleshooting

- **Port 3333 in use:** The `run.sh` script attempts to kill processes on port 3333. If it fails, run `sudo fuser -k 3333/tcp` manually.

## Credits

- **Obico:** [TheSpaghettiDetective/obico-server](https://github.com/TheSpaghettiDetective/obico-server)
- **Jetson Containers:** [dusty-nv/jetson-containers](https://github.com/dusty-nv/jetson-containers)
- **Darknet:** [AlexeyAB/darknet](https://github.com/AlexeyAB/darknet)
