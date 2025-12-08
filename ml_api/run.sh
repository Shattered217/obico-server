#!/bin/bash

# --- 配置区域 ---
CONTAINER_NAME="obico_ml_container"
IMAGE_NAME="obico-server-final"
PORT=3333
TOKEN=${ML_API_TOKEN:-"bambu_nb"}
# ----------------

echo "🚀 准备启动 Obico ML API..."

# 1. 清理旧容器
if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "🧹 发现旧容器，正在停止并删除..."
    sudo docker stop "$CONTAINER_NAME" >/dev/null 2>&1
    sudo docker rm "$CONTAINER_NAME" >/dev/null 2>&1
fi

# 2. 暴力清理端口占用 (防止 Address already in use)
if sudo lsof -i :$PORT >/dev/null 2>&1; then
    echo "⚠️  端口 $PORT 被占用，正在强制释放..."
    sudo fuser -k -n tcp $PORT >/dev/null 2>&1
    sleep 1
fi

# 3. 启动新容器
echo "🔥 启动新容器..."
# 参数解释：
# --runtime nvidia: 必须，否则无法调用 GPU (现在我们在 build.sh 里配置了 default-runtime，但显式加上更保险)
# --network host: 让容器直接使用宿主机 IP，解决访问 Home Assistant 问题
sudo docker run -d \
  --runtime nvidia \
  --network host \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -e ML_API_TOKEN="$TOKEN" \
  -e TZ="Asia/Shanghai" \
  "$IMAGE_NAME"

# 4. 检查启动状态
if [ $? -eq 0 ]; then
    #echo "✅ 服务已在后台启动！"
    #echo "📝 正在输出最后 10 行日志 (按 Ctrl+C 退出日志查看，服务不会停止):"
    #echo "-----------------------------------------------------"
    #sleep 2
    #sudo docker logs -f --tail 10 "$CONTAINER_NAME"
    echo "(无头模式)"
else
    echo "❌ 启动失败。"
fi