#!/bin/bash

# 基于JDK8的GDAL 2.4.0镜像构建脚本（支持多架构）

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

# 配置变量
REGISTRY=${REGISTRY:-""}
IMAGE_NAME=${IMAGE_NAME:-"gdal-jdk8-gdal240"}
TAG=${TAG:-"2.4.0-jdk8"}
PLATFORMS=${PLATFORMS:-"linux/amd64,linux/arm64"}
BUILD_ARGS=${BUILD_ARGS:-""}
PUSH=${PUSH:-"false"}
NO_CACHE=${NO_CACHE:-"false"}

# 完整镜像名称
if [ -n "$REGISTRY" ]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}"
else
    FULL_IMAGE_NAME="${IMAGE_NAME}"
fi

# 显示构建信息
show_build_info() {
    log_info "=== GDAL JDK8 GDAL2.4.0镜像构建配置 ==="
    log_info "镜像名称: ${FULL_IMAGE_NAME}:${TAG}"
    log_info "支持平台: ${PLATFORMS}"
    log_info "构建参数: ${BUILD_ARGS}"
    log_info "推送到仓库: ${PUSH}"
    log_info "使用缓存: $([ "$NO_CACHE" = "true" ] && echo "否" || echo "是")"
    echo
}

# 检查依赖
check_dependencies() {
    log_info "检查构建依赖..."
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装或不在PATH中"
        exit 1
    fi
    
    # 检查Docker Buildx
    if ! docker buildx version &> /dev/null; then
        log_error "Docker Buildx未安装或不可用"
        exit 1
    fi
    
    # 检查Dockerfile
    if [ ! -f "Dockerfile_jdk8_gdal240" ]; then
        log_error "当前目录下没有找到Dockerfile_jdk8_gdal240"
        exit 1
    fi
    
    log_success "依赖检查通过"
}

# 创建或使用buildx构建器
setup_builder() {
    log_info "设置Docker Buildx构建器..."
    
    BUILDER_NAME="gdal-jdk8-gdal240-builder"
    
    # 检查构建器是否存在
    if docker buildx inspect "$BUILDER_NAME" &> /dev/null; then
        log_info "使用现有构建器: $BUILDER_NAME"
        docker buildx use "$BUILDER_NAME"
    else
        log_info "创建新的构建器: $BUILDER_NAME"
        # 确保启用了多架构支持
        docker run --privileged --rm tonistiigi/binfmt --install all
        docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
        docker buildx inspect --bootstrap
    fi
    
    log_success "构建器设置完成"
}

# 构建镜像
build_image() {
    log_info "开始构建GDAL JDK8 GDAL2.4.0多架构镜像..."
    
    # 构建命令参数
    BUILD_CMD="docker buildx build"
    BUILD_CMD="$BUILD_CMD --platform $PLATFORMS"
    BUILD_CMD="$BUILD_CMD --tag ${FULL_IMAGE_NAME}:${TAG}"
    BUILD_CMD="$BUILD_CMD -f Dockerfile_jdk8_gdal240"
    
    # 添加构建参数
    if [ -n "$BUILD_ARGS" ]; then
        BUILD_CMD="$BUILD_CMD $BUILD_ARGS"
    fi
    
    # 缓存设置
    if [ "$NO_CACHE" = "true" ]; then
        BUILD_CMD="$BUILD_CMD --no-cache"
    fi
    
    # 推送设置
    if [ "$PUSH" = "true" ]; then
        BUILD_CMD="$BUILD_CMD --push"
    else
        BUILD_CMD="$BUILD_CMD --load"
        log_warning "镜像将只构建到本地，不会推送到仓库"
    fi
    
    # 添加当前目录作为构建上下文
    BUILD_CMD="$BUILD_CMD ."
    
    log_info "执行构建命令: $BUILD_CMD"
    
    # 记录构建开始时间
    START_TIME=$(date +%s)
    
    # 执行构建
    if eval "$BUILD_CMD"; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        log_success "镜像构建成功，耗时: ${DURATION}秒"
    else
        log_error "镜像构建失败"
        exit 1
    fi
}

# 验证构建结果
verify_build() {
    if [ "$PUSH" = "false" ]; then
        log_info "验证本地镜像..."
        
        # 检查镜像是否存在
        if docker images "${FULL_IMAGE_NAME}" | grep -q "${TAG}"; then
            log_success "本地镜像验证通过"
            
            # 显示镜像信息
            log_info "镜像详细信息:"
            docker images "${FULL_IMAGE_NAME}:${TAG}" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedAt}}"
        else
            log_error "本地镜像验证失败"
            exit 1
        fi
    else
        log_info "镜像已推送到仓库，跳过本地验证"
    fi
}

# 显示使用帮助
show_help() {
    cat << EOF
用法: $0 [选项]

选项:
    -r, --registry REGISTRY     镜像仓库地址 (默认: 无)
    -n, --name NAME            镜像名称 (默认: gdal-jdk8-gdal240)
    -t, --tag TAG              镜像标签 (默认: 2.4.0-jdk8)
    -p, --platforms PLATFORMS  支持平台 (默认: linux/amd64,linux/arm64)
    --push                     构建后推送到仓库
    --no-cache                 不使用缓存构建
    -h, --help                 显示帮助信息

环境变量:
    REGISTRY                   镜像仓库地址
    IMAGE_NAME                 镜像名称
    TAG                        镜像标签
    PLATFORMS                  支持的平台列表
    BUILD_ARGS                 额外的构建参数
    PUSH                       是否推送 (true/false)
    NO_CACHE                   是否禁用缓存 (true/false)

示例:
    # 基本构建
    $0

    # 构建并推送到仓库
    $0 --push --registry your-registry.com

    # 使用自定义标签构建
    $0 --tag v1.0.0 --no-cache

    # 只构建AMD64架构
    $0 --platforms linux/amd64
EOF
}

# 主函数
main() {
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--registry)
                REGISTRY="$2"
                shift 2
                ;;
            -n|--name)
                IMAGE_NAME="$2"
                shift 2
                ;;
            -t|--tag)
                TAG="$2"
                shift 2
                ;;
            -p|--platforms)
                PLATFORMS="$2"
                shift 2
                ;;
            --push)
                PUSH="true"
                shift
                ;;
            --no-cache)
                NO_CACHE="true"
                shift
                ;;
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
    
    # 重新计算完整镜像名称
    if [ -n "$REGISTRY" ]; then
        FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}"
    else
        FULL_IMAGE_NAME="${IMAGE_NAME}"
    fi
    
    # 执行构建流程
    show_build_info
    check_dependencies
    setup_builder
    build_image
    verify_build
    
    log_success "GDAL JDK8 GDAL2.4.0多架构镜像构建完成！"
    log_info "镜像名称: ${FULL_IMAGE_NAME}:${TAG}"
    log_info "支持平台: ${PLATFORMS}"
    
    echo
    log_info "可以使用以下命令运行容器:"
    echo "docker run -it --rm -v \$(pwd)/data:/data ${FULL_IMAGE_NAME}:${TAG}"
    echo
}

# 执行主函数
main "$@"