#!/bin/bash

# GDAL OpenJDK多架构镜像测试脚本

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

# 测试镜像在不同架构下的功能
test_multi_arch() {
    local image_name=$1
    local tag=$2
    
    if [ -z "$image_name" ] || [ -z "$tag" ]; then
        log_error "请提供镜像名称和标签"
        exit 1
    fi
    
    local full_image="${image_name}:${tag}"
    
    log_info "开始测试多架构镜像: $full_image"
    
    # 测试的平台
    local platforms=("linux/amd64" "linux/arm64")
    
    for platform in "${platforms[@]}"; do
        log_info "测试平台: $platform"
        
        # 确保QEMU仿真器可用
        log_info "确保QEMU仿真器可用..."
        docker run --privileged --rm tonistiigi/binfmt:latest --install $platform
        
        # 拉取特定平台的镜像
        log_info "拉取 $platform 平台的镜像..."
        if ! docker pull --platform=$platform $full_image; then
            log_error "无法拉取 $platform 平台的镜像"
            continue
        fi
        
        # 测试GDAL功能
        log_info "测试GDAL功能..."
        if docker run --rm --platform=$platform $full_image gdalinfo --version; then
            log_success "$platform 平台 GDAL功能测试通过"
        else
            log_error "$platform 平台 GDAL功能测试失败"
        fi
        
        # 测试Java功能
        log_info "测试Java功能..."
        if docker run --rm --platform=$platform $full_image java -version; then
            log_success "$platform 平台 Java功能测试通过"
        else
            log_error "$platform 平台 Java功能测试失败"
        fi
        
        # 测试GDAL Java绑定
        log_info "测试GDAL Java绑定..."
        if docker run --rm --platform=$platform $full_image ls -la /usr/local/share/java/gdal.jar; then
            log_success "$platform 平台 GDAL Java绑定测试通过"
        else
            log_error "$platform 平台 GDAL Java绑定测试失败"
        fi
        
        echo ""
    done
    
    log_success "多架构测试完成"
}

# 显示使用帮助
show_help() {
    cat << EOF
用法: $0 <镜像名称> <标签>

参数:
    镜像名称    要测试的镜像名称
    标签        镜像标签

示例:
    $0 gdal-openjdk 3.7.1-openjdk8u342
    $0 my-registry.com/gdal-openjdk 3.7.1-openjdk8u342
EOF
}

# 主函数
main() {
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        show_help
        exit 0
    fi
    
    if [ $# -ne 2 ]; then
        log_error "参数数量不正确"
        show_help
        exit 1
    fi
    
    test_multi_arch "$1" "$2"
}

# 执行主函数
main "$@"