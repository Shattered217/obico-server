#!/bin/bash
set -e # 遇到错误立即停止

# 确保在脚本所在目录运行
cd "$(dirname "$0")"
WORK_DIR=$(pwd)

echo "🔧 [1/5] 检查并配置 jetson-containers..."

# 1.1 克隆仓库
if [ ! -d "jetson-containers" ]; then
    echo "   正在克隆 jetson-containers..."
    git clone https://github.com/dusty-nv/jetson-containers
else
    echo "   jetson-containers 已存在，跳过克隆。"
fi

# 1.2 安装依赖
echo "   正在安装 jetson-containers 依赖..."
cd jetson-containers
bash install.sh
cd "$WORK_DIR"

# 2. 配置 Docker Daemon (NVIDIA Runtime)
echo "🐳 [2/5] 配置 Docker NVIDIA Runtime..."

# 定义用户提供的 JSON 内容
CONFIG_CONTENT='{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}'

# 检查是否需要更新 daemon.json
# 只有当文件不存在或内容不匹配时才写入，避免重复重启
if [ ! -f "/etc/docker/daemon.json" ] || ! grep -q "nvidia-container-runtime" "/etc/docker/daemon.json"; then
    echo "   正在写入 /etc/docker/daemon.json ..."
    # 备份旧文件
    if [ -f "/etc/docker/daemon.json" ]; then
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
        echo "   (已备份旧配置到 daemon.json.bak)"
    fi
    
    # 写入新配置
    echo "$CONFIG_CONTENT" | sudo tee /etc/docker/daemon.json > /dev/null
    
    # 重启 Docker
    echo "   正在重启 Docker 服务..."
    sudo systemctl restart docker
    sleep 3 # 等待 Docker 启动
else
    echo "   Docker 配置看起来正确，跳过。"
fi

# 3. 构建基础镜像 (Base Image)
echo "🏗️ [3/5] 使用 jetson-containers 构建基础镜像 (obico)..."
echo "   这可能需要一些时间，请耐心等待..."

# 运行 jetson-containers build
# 这会自动检测 JetPack 版本并构建正确的镜像
jetson-containers build --name=obico onnxruntime opencv

# 4. 链接基础镜像
echo "🔗 [4/5] 准备应用构建环境..."

# 获取刚才构建的 obico 镜像的完整 Tag (通常是 obico:r36.x.x...)
# 我们取最新的一个 obico 镜像
LATEST_BASE_IMAGE=$(sudo docker images --format "{{.Repository}}:{{.Tag}}" | grep "^obico:" | head -n 1)

if [ -z "$LATEST_BASE_IMAGE" ]; then
    echo "❌ 错误: 未找到 jetson-containers 构建的 obico 镜像！"
    exit 1
fi

echo "   检测到基础镜像: $LATEST_BASE_IMAGE"
echo "   正在将其标记为 obico:base 以供 Dockerfile.app 使用..."
sudo docker tag "$LATEST_BASE_IMAGE" obico:base

# 修改 Dockerfile.app 的 FROM 行，确保它指向我们刚才标记的 obico:base
# 这样无论 JetPack 版本怎么变，Dockerfile.app 都不用手动改
sed -i 's/^FROM .*/FROM obico:base/' Dockerfile.app

# 5. 构建最终应用镜像
echo "🚀 [5/5] 构建最终应用镜像 (obico-server-final)..."

# 检查 Makefile 是否存在
if [ ! -f "Makefile" ]; then
    echo "❌ 错误: 当前目录下找不到 Makefile。"
    exit 1
fi

# 构建
sudo docker build -t obico-server-final -f Dockerfile.app .

echo "------------------------------------------------"
echo "✅ 部署完成！"
echo "   基础镜像来源: $LATEST_BASE_IMAGE"
echo "   最终应用镜像: obico-server-final"
echo "   请运行 ./run.sh 启动服务。"
echo "------------------------------------------------"