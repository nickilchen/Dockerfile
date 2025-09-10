#!/bin/bash

# GDAL Java绑定修复验证脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "=== GDAL Java绑定修复验证脚本 ==="
echo

# 步骤1：清理旧镜像和缓存
log_info "步骤1: 清理旧镜像和缓存..."
docker system prune -af
log_success "清理完成"
echo

# 步骤2：重新构建镜像
log_info "步骤2: 重新构建镜像..."
if docker build -t gdal-multi-arch:latest .; then
    log_success "镜像构建成功"
else
    log_error "镜像构建失败"
    exit 1
fi
echo

# 步骤3：验证镜像基本功能
log_info "步骤3: 验证镜像基本功能..."

# 验证GDAL版本
log_info "验证GDAL版本..."
GDAL_VERSION=$(docker run --rm gdal-multi-arch:latest gdalinfo --version | grep -o "GDAL [0-9.]*" | head -1)
if [[ "$GDAL_VERSION" == "GDAL 3.7.1" ]]; then
    log_success "GDAL版本验证通过: $GDAL_VERSION"
else
    log_error "GDAL版本验证失败: $GDAL_VERSION"
    exit 1
fi

# 验证Java版本
log_info "验证Java版本..."
JAVA_VERSION=$(docker run --rm gdal-multi-arch:latest java -version 2>&1 | grep "version" | head -1)
if echo "$JAVA_VERSION" | grep -q "1.8"; then
    log_success "Java版本验证通过: $JAVA_VERSION"
else
    log_error "Java版本验证失败: $JAVA_VERSION"
    exit 1
fi

# 验证Java GDAL绑定
log_info "验证Java GDAL绑定..."
if docker run --rm gdal-multi-arch:latest ls -la /usr/share/java/gdal.jar > /dev/null 2>&1; then
    log_success "Java GDAL绑定文件存在"
else
    log_error "Java GDAL绑定文件不存在"
    exit 1
fi

# 验证native库
log_info "验证native库..."
if docker run --rm gdal-multi-arch:latest find /usr/lib -name "*gdal*" -type f | grep -q "gdal"; then
    log_success "GDAL native库文件存在"
else
    log_error "GDAL native库文件不存在"
    exit 1
fi

echo
log_success "=== 所有验证测试通过！==="
echo

# 显示镜像信息
log_info "镜像详细信息:"
docker images gdal-multi-arch:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedAt}}"
echo

# 提供使用建议
log_info "使用建议:"
echo "1. 运行交互式容器:"
echo "   docker run -it --rm -v \$(pwd)/data:/data gdal-multi-arch:latest"
echo
echo "2. 使用docker-compose:"
echo "   docker-compose up -d"
echo
echo "3. 测试Java GDAL绑定:"
echo "   docker run --rm -v \$(pwd):/workspace gdal-multi-arch:latest \\"
echo "     bash -c 'javac -cp /usr/share/java/gdal.jar GdalTest.java && java -cp .:/usr/share/java/gdal.jar -Djava.library.path=/usr/lib GdalTest'"