# 多架构GDAL镜像 - 基于Alpine Linux，集成GDAL 3.7.1和Oracle JDK 8
# 专注于Java集成，不包含Python支持
# 支持架构: linux/amd64, linux/arm64

FROM alpine:latest

# 设置标签信息
LABEL maintainer="GDAL Multi-arch Image"
LABEL description="Alpine-based GDAL 3.7.1 image with Oracle JDK 8 support for Java integration only"
LABEL version="1.0.0"
LABEL gdal.version="3.7.1"
LABEL java.version="Oracle JDK 8"
LABEL features="java-only,no-python"

# 设置环境变量
ENV GDAL_VERSION=3.7.1
ENV GDAL_DATA=/usr/share/gdal
ENV JAVA_HOME=/opt/java/jdk8
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=/usr/share/java/gdal.jar

# 创建非root用户
RUN addgroup -g 1000 gdaluser && \
    adduser -D -u 1000 -G gdaluser gdaluser

# 安装系统依赖和构建工具（移除Python相关）
RUN apk update && \
    apk add --no-cache \
        # 基础工具
        bash \
        curl \
        wget \
        ca-certificates \
        tar \
        gzip \
        # 构建工具
        build-base \
        cmake \
        make \
        gcc \
        g++ \
        # Linux内核头文件（解决linux/fs.h问题）
        linux-headers \
        # GDAL编译依赖
        sqlite-dev \
        proj-dev \
        geos-dev \
        expat-dev \
        zlib-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        tiff-dev \
        libgeotiff-dev \
        openjpeg-dev \
        # Java开发工具
        swig \
        # 其他工具
        git \
    && rm -rf /var/cache/apk/*

# 下载并安装Oracle JDK 8
RUN mkdir -p /opt/java && \
    cd /tmp && \
    # 使用Zulu JDK作为Oracle JDK的兼容替代（因为Oracle JDK需要许可证）
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        JDK_ARCH="x64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        JDK_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    JDK_URL="https://cdn.azul.com/zulu/bin/zulu8.78.0.19-ca-jdk8.0.412-linux_musl_${JDK_ARCH}.tar.gz" && \
    wget -O jdk8.tar.gz "$JDK_URL" && \
    tar -xzf jdk8.tar.gz -C /opt/java && \
    mv /opt/java/zulu8* /opt/java/jdk8 && \
    rm -f jdk8.tar.gz

# 编译安装GDAL 3.7.1（只启用Java绑定）
RUN cd /tmp && \
    wget https://github.com/OSGeo/gdal/releases/download/v${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz && \
    tar -xzf gdal-${GDAL_VERSION}.tar.gz && \
    cd gdal-${GDAL_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DGDAL_USE_GEOS=ON \
        -DGDAL_USE_SQLITE3=ON \
        -DGDAL_USE_PROJ=ON \
        -DGDAL_USE_JPEG=ON \
        -DGDAL_USE_PNG=ON \
        -DGDAL_USE_TIFF=ON \
        -DGDAL_USE_GEOTIFF=ON \
        -DGDAL_USE_OPENJPEG=ON \
        -DBUILD_PYTHON_BINDINGS=OFF \
        -DBUILD_JAVA_BINDINGS=ON \
        -DJAVA_HOME=$JAVA_HOME \
        -DSWIG_EXECUTABLE=/usr/bin/swig \
        -DACCEPT_MISSING_LINUX_FS_HEADER:BOOL=ON && \
    make -j$(nproc) && \
    make install && \
    # 安装Java绑定
    mkdir -p /usr/share/java && \
    cp swig/java/gdal.jar /usr/share/java/ && \
    cp swig/java/*.so /usr/lib/ && \
    ldconfig && \
    cd / && \
    rm -rf /tmp/gdal-${GDAL_VERSION}*

# 清理构建依赖（保留运行时依赖）
RUN apk del \
        build-base \
        cmake \
        make \
        gcc \
        g++ \
        git \
        swig && \
    rm -rf /var/cache/apk/* /tmp/*

# 验证GDAL安装
RUN gdalinfo --version && \
    echo "GDAL ${GDAL_VERSION} installation verified" && \
    # 验证GDAL版本
    gdal-config --version | grep -q "${GDAL_VERSION}" && \
    echo "GDAL version check passed" && \
    # 验证Java GDAL绑定
    ls -la /usr/share/java/gdal.jar && \
    echo "Java GDAL bindings installed"

# 验证Java安装
RUN java -version && \
    echo "Oracle JDK 8 compatible installation verified" && \
    # 验证Java版本
    java -version 2>&1 | grep -q "1.8" && \
    echo "Java version check passed" && \
    # 验证CLASSPATH设置
    echo "CLASSPATH: $CLASSPATH"

# 创建工作目录
RUN mkdir -p /data /workspace && \
    chown -R gdaluser:gdaluser /data /workspace

# 设置工作目录
WORKDIR /workspace

# 切换到非root用户
USER gdaluser

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD gdalinfo --version || exit 1

# 默认命令
CMD ["bash"]