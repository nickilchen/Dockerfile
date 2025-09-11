#FROM ringcentral/jdk:8u432
FROM registry.cn-hangzhou.aliyuncs.com/nickilchen/jdk:8u432

# 设置维护者信息
LABEL maintainer="your.name@example.com"
LABEL description="Docker image with JDK 8 and GDAL 3.7.1 on Ubuntu"

# 设置非交互式前端以避免提示
ENV DEBIAN_FRONTEND=noninteractive

ARG GDAL_VERSION=3.7.1

#RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources && \
#    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.source

# 替换 Ubuntu 官方端口源为阿里云镜像源（适用于 ARM64 架构）
# RUN if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
#         sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources && \
#         sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources; \
#     elif [ -f /etc/apt/sources.list ]; then \
#         sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
#         sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list; \
#     else \
#         echo "Warning: No common Ubuntu sources list file found."; \
#     fi

# 更新包列表并安装编译工具和依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        pkg-config \
        ninja-build \
        curl \
        wget \
        # GDAL 依赖
        libproj-dev \
        libgeos-dev \
        libtiff5-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        zlib1g-dev \
        libexpat1-dev \
        libsqlite3-dev \
        # Java 绑定需要的工具
        swig \
        libxml2-dev \
        ant && \
    # 清理缓存以减少镜像大小
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /tmp

#COPY ./gdal-3.7.1.tar.gz /tmp

# 下载并编译安装 GDAL 3.7.1
RUN RUN cd /tmp && \
    wget https://github.com/OSGeo/gdal/releases/download/v${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz && \
    tar -xzf gdal-${GDAL_VERSION}.tar.gz && \
    mkdir -p gdal-${GDAL_VERSION}/build && \
    cd gdal-${GDAL_VERSION}/build && \
    # 使用 CMake 配置 GDAL，启用 Java 绑定
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_JAVA_BINDINGS=ON \
        -DBUILD_PYTHON_BINDINGS=OFF \
        -DBUILD_APPS=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_STATIC_LIBS=OFF \
        -DGDAL_USE_GEOTIFF_INTERNAL=ON \
        -DGDAL_USE_OPENJPEG_INTERNAL=ON \
        -DGDAL_USE_LIBXML2=ON \
        -DGDAL_USE_SQLITE3=ON \
        -DGDAL_USE_PROJ=ON \
        -DGDAL_USE_GEOS=ON && \
    # 编译并安装
    make -j$(nproc) && \
    make install

RUN cd /tmp/gdal-${GDAL_VERSION}/build/swig/java && \
    make && \
    make install

RUN cd /tmp && \
    rm -rf gdal-${GDAL_VERSION}* && \
    # 更新动态库缓存
    ldconfig

# 设置 GDAL 相关的环境变量
ENV CLASSPATH=/usr/local/share/java/gdal-3.7.1.jar:$CLASSPATH
ENV LD_LIBRARY_PATH=/usr/local/share/java:$LD_LIBRARY_PATH

## 验证安装
RUN java -version && \
    gdalinfo --version

# 设置容器启动后的默认工作目录
WORKDIR /workspace

# 指定默认命令
CMD ["/bin/bash"]