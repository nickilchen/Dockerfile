#!/bin/bash

# PostGIS镜像测试脚本

set -e

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 测试PostGIS镜像功能
test_postgis() {
    local image_name=$1
    local platform=$2
    
    if [ -z "$image_name" ]; then
        log_error "请提供镜像名称"
        exit 1
    fi
    
    if [ -z "$platform" ]; then
        platform="linux/amd64"
    fi
    
    log_info "开始测试PostGIS镜像: $image_name (平台: $platform)"
    
    # 确保QEMU仿真器可用
    log_info "确保QEMU仿真器可用..."
    docker run --privileged --rm tonistiigi/binfmt:latest --install $platform
    
    # 拉取镜像
    log_info "拉取镜像..."
    docker pull --platform=$platform $image_name
    
    # 启动容器
    log_info "启动PostGIS容器..."
    docker run -d \
      --name test-postgis \
      --platform=$platform \
      -e POSTGRES_PASSWORD=testpass \
      -e POSTGRES_USER=testuser \
      -e POSTGRES_DB=testdb \
      $image_name
    
    # 等待数据库启动
    log_info "等待数据库启动..."
    TIMEOUT=60
    COUNT=0
    until docker exec test-postgis pg_isready -U testuser -d testdb || [ $COUNT -gt $TIMEOUT ]; do
        log_info "⏳ PostgreSQL仍在启动中..."
        sleep 5
        COUNT=$((COUNT + 5))
    done
    
    if [ $COUNT -gt $TIMEOUT ]; then
        log_error "PostgreSQL启动超时"
        docker logs test-postgis
        cleanup
        exit 1
    fi
    
    # 测试PostgreSQL连接
    log_info "测试PostgreSQL连接..."
    if docker exec test-postgis pg_isready -U testuser -d testdb; then
        log_success "PostgreSQL连接测试通过"
    else
        log_error "PostgreSQL连接测试失败"
        docker logs test-postgis
        cleanup
        exit 1
    fi
    
    # 测试PostGIS扩展
    log_info "测试PostGIS扩展..."
    if docker exec test-postgis psql -U testuser -d testdb -c "SELECT PostGIS_Version();"; then
        log_success "PostGIS扩展测试通过"
    else
        log_error "PostGIS扩展测试失败"
        docker logs test-postgis
        cleanup
        exit 1
    fi
    
    # 测试PostGIS功能
    log_info "测试PostGIS功能..."
    if docker exec test-postgis psql -U testuser -d testdb -c "SELECT ST_GeomFromText('POINT(0 0)');"; then
        log_success "PostGIS功能测试通过"
    else
        log_error "PostGIS功能测试失败"
        docker logs test-postgis
        cleanup
        exit 1
    fi
    
    # 列出已安装的扩展
    log_info "列出已安装的扩展..."
    docker exec test-postgis psql -U testuser -d testdb -c "\dx"
    
    # 清理
    cleanup
    log_success "PostGIS镜像测试完成"
}

# 清理测试资源
cleanup() {
    log_info "清理测试资源..."
    docker stop test-postgis 2>/dev/null || true
    docker rm test-postgis 2>/dev/null || true
}

# 显示使用帮助
show_help() {
    cat << EOF
用法: $0 <镜像名称> [平台]

参数:
    镜像名称    要测试的镜像名称
    平台        目标平台 (默认: linux/amd64)

示例:
    $0 postgis/postgis:13-3.5
    $0 postgis/postgis:13-3.5 linux/arm64
    $0 your-registry.com/postgis:13-3.5 linux/amd64
EOF
}

# 主函数
main() {
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi
    
    if [ $# -lt 1 ]; then
        log_error "参数数量不正确"
        show_help
        exit 1
    fi
    
    trap cleanup EXIT
    test_postgis "$1" "$2"
}

# 执行主函数
main "$@"