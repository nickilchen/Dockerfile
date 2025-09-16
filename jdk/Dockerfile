# 基于Alpine Linux的最小JDK 8镜像
# 使用本地JDK包制作，以达到最小空间占用

FROM alpine:latest

# 设置标签信息
LABEL maintainer="Minimal JDK8 Image"
LABEL description="Minimal OpenJDK 8 image based on Alpine Linux with local JDK package"
LABEL version="1.0.0"
LABEL java.version="OpenJDK 8u431"

# 设置环境变量
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# 安装必要的系统工具
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# 创建Java目录
RUN mkdir -p /opt/java

# 复制本地JDK包并解压
COPY jdk-8u431-linux-x64.tar.gz /tmp/
RUN cd /tmp && \
    tar -xzf jdk-8u431-linux-x64.tar.gz && \
    mv jdk1.8.0_431 $JAVA_HOME && \
    rm -f /tmp/jdk-8u431-linux-x64.tar.gz

# 创建非root用户
RUN addgroup -g 1000 javauser && \
    adduser -D -u 1000 -G javauser javauser

# 清理不必要的文件以减小镜像大小
RUN rm -rf $JAVA_HOME/man \
    $JAVA_HOME/sample \
    $JAVA_HOME/plugin \
    $JAVA_HOME/bin/javaws \
    $JAVA_HOME/bin/pack200 \
    $JAVA_HOME/bin/unpack200 \
    $JAVA_HOME/bin/rmid \
    $JAVA_HOME/bin/rmiregistry \
    $JAVA_HOME/bin/keytool \
    $JAVA_HOME/bin/kinit \
    $JAVA_HOME/bin/klist \
    $JAVA_HOME/bin/ktab \
    $JAVA_HOME/bin/policytool \
    $JAVA_HOME/bin/servertool \
    $JAVA_HOME/bin/tnameserv \
    $JAVA_HOME/bin/jjs \
    $JAVA_HOME/bin/jcontrol \
    $JAVA_HOME/bin/jconsole \
    $JAVA_HOME/bin/jvisualvm \
    $JAVA_HOME/bin/jhat \
    $JAVA_HOME/bin/jinfo \
    $JAVA_HOME/bin/jmap \
    $JAVA_HOME/bin/jps \
    $JAVA_HOME/bin/jrunscript \
    $JAVA_HOME/bin/jstack \
    $JAVA_HOME/bin/jstat \
    $JAVA_HOME/bin/jstatd \
    $JAVA_HOME/bin/rmic \
    $JAVA_HOME/bin/schemagen \
    $JAVA_HOME/bin/wsgen \
    $JAVA_HOME/bin/wsimport \
    $JAVA_HOME/bin/xjc \
    $JAVA_HOME/lib/src.zip \
    $JAVA_HOME/lib/missioncontrol \
    $JAVA_HOME/lib/visualvm \
    $JAVA_HOME/lib/*javafx* \
    $JAVA_HOME/lib/*jfx* \
    $JAVA_HOME/lib/amd64/libdecora_sse.so \
    $JAVA_HOME/lib/amd64/libprism_*.so \
    $JAVA_HOME/lib/amd64/libfxplugins.so \
    $JAVA_HOME/lib/amd64/libglass.so \
    $JAVA_HOME/lib/amd64/libgstreamer-lite.so \
    $JAVA_HOME/lib/amd64/libjavafx*.so \
    $JAVA_HOME/lib/amd64/libjfx*.so \
    $JAVA_HOME/lib/ext/jfxrt.jar \
    $JAVA_HOME/lib/ext/nashorn.jar \
    $JAVA_HOME/lib/ext/cldrdata.jar \
    $JAVA_HOME/lib/ext/dnsns.jar \
    $JAVA_HOME/lib/ext/localedata.jar \
    $JAVA_HOME/lib/ext/sunec.jar \
    $JAVA_HOME/lib/ext/sunjce_provider.jar \
    $JAVA_HOME/lib/ext/sunpkcs11.jar \
    $JAVA_HOME/lib/ext/zipfs.jar \
    $JAVA_HOME/lib/javafx.properties \
    $JAVA_HOME/lib/jfr.jar \
    $JAVA_HOME/lib/jfr \
    $JAVA_HOME/lib/oblique-fonts

# 验证Java安装
RUN java -version && \
    echo "OpenJDK 8u431 installation verified"

# 创建工作目录
RUN mkdir -p /workspace && \
    chown -R javauser:javauser /workspace

# 设置工作目录
WORKDIR /workspace

# 切换到非root用户
USER javauser

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD java -version || exit 1

# 默认命令
CMD ["bash"]