#!/bin/bash

# 测试GDAL 2.4.0镜像构建脚本

set -e  # 遇到错误时退出

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

# 测试函数
test_build() {
    log_info "开始测试GDAL JDK8 GDAL2.4.0镜像构建..."
    
    # 检查Dockerfile是否存在
    if [ ! -f "Dockerfile_jdk8_gdal240" ]; then
        log_error "未找到Dockerfile_jdk8_gdal240文件"
        exit 1
    fi
    
    # 检查Docker是否可用
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装或不在PATH中"
        exit 1
    fi
    
    # 检查Docker Buildx是否可用
    if ! docker buildx version &> /dev/null; then
        log_error "Docker Buildx未安装或不可用"
        exit 1
    fi
    
    # 创建buildx构建器（如果不存在）
    BUILDER_NAME="test-gdal240-builder"
    if ! docker buildx inspect "$BUILDER_NAME" &> /dev/null; then
        log_info "创建测试构建器: $BUILDER_NAME"
        docker buildx create --name "$BUILDER_NAME" --driver docker-container
    fi
    
    # 使用构建器
    docker buildx use "$BUILDER_NAME"
    
    # 构建镜像（仅构建，不推送）
    log_info "开始构建镜像（仅AMD64架构）..."
    BUILD_START_TIME=$(date +%s)
    
    if docker buildx build \
        --platform linux/amd64 \
        --tag gdal-jdk8-gdal240:test \
        -f Dockerfile_jdk8_gdal240 \
        --load \
        .; then
        
        BUILD_END_TIME=$(date +%s)
        BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
        log_success "镜像构建成功，耗时: ${BUILD_DURATION}秒"
        
        # 验证镜像是否存在
        if docker images | grep -q "gdal-jdk8-gdal240.*test"; then
            log_success "镜像验证通过"
            
            # 显示镜像信息
            log_info "镜像信息:"
            docker images gdal-jdk8-gdal240:test --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
            
            # 清理测试镜像
            docker rmi gdal-jdk8-gdal240:test
            log_info "已清理测试镜像"
        else
            log_error "镜像验证失败"
            exit 1
        fi
    else
        log_error "镜像构建失败"
        exit 1
    fi
    
    # 清理构建器
    docker buildx use default
    docker buildx rm "$BUILDER_NAME"
    
    log_success "GDAL JDK8 GDAL2.4.0镜像构建测试完成！"
}

# 显示使用帮助
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
    -h, --help     显示帮助信息

示例:
    # 运行测试
    $0
EOF
}

# 主函数
main() {
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 执行测试
    test_build
}

# 执行主函数
main "$@"