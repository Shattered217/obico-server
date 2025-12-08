# 1. 基础镜像 (JetPack 6 + CUDA 12.6 + OpenCV)
FROM obico:r36.4.tegra-aarch64-cu126-22.04-opencv

# --------------------------------------------------------
# 第一部分：编译 Darknet (完全模仿官方路径)
# --------------------------------------------------------
WORKDIR /darknet

# 环境变量
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# 克隆源码
RUN git clone https://github.com/AlexeyAB/darknet .

# 复制你本地改好的 Makefile (必须包含 GPU=1, CUDNN=1, OPENCV=1, ARCH=compute_87)
COPY Makefile ./Makefile

# 链接 CUDA Stubs 以修复编译链接错误
RUN ln -sf /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/libcuda.so

# 编译并重命名 (关键：生成 code 期待的 libdarknet_gpu.so)
RUN make -j$(nproc) && \
    cp libdarknet.so libdarknet_gpu.so && \
    cp libdarknet.so libdarknet_cpu.so

# 清理链接
RUN rm /usr/local/cuda/lib64/libcuda.so

# --------------------------------------------------------
# 第二部分：配置应用环境
# --------------------------------------------------------
WORKDIR /app

# 安装依赖
COPY requirements.txt /app/
# 技巧：grep -v 排除掉 requirements.txt 里的 onnxruntime，
# 强制使用基础镜像里自带的 GPU 加速版，防止 pip 下载 CPU 版覆盖
RUN grep -v "onnxruntime" requirements.txt > requirements_cleaned.txt && \
    pip3 install --no-cache-dir -r requirements_cleaned.txt || true

# 复制应用代码
COPY . /app

# --------------------------------------------------------
# 第三部分：下载模型权重 (补上官方 Dockerfile 的逻辑)
# --------------------------------------------------------
# 确保 model 目录存在
RUN mkdir -p model

# 下载 Darknet 权重
RUN if [ -f model/model-weights.darknet.url ]; then \
        wget -O model/model-weights.darknet $(cat model/model-weights.darknet.url | tr -d '\r'); \
    else \
        echo "Warning: .url file not found, skipping download"; \
    fi

# 下载 ONNX 权重
RUN if [ -f model/model-weights.onnx.url ]; then \
        wget -O model/model-weights.onnx $(cat model/model-weights.onnx.url | tr -d '\r'); \
    else \
        echo "Warning: .url file not found, skipping download"; \
    fi

# --------------------------------------------------------
# 第四部分：启动配置
# --------------------------------------------------------
# 关键：把 /darknet 加入 library path，虽然代码是硬编码路径，但这样更稳
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/darknet"
ENV PYTHONUNBUFFERED=1

EXPOSE 3333
CMD ["gunicorn", "--bind", "0.0.0.0:3333", "--workers", "1", "server:app"]