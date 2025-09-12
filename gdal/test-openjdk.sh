#!/bin/bash

# 测试基于OpenJDK的GDAL镜像脚本（支持多架构）

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

# 默认测试平台
TEST_PLATFORMS=("linux/amd64" "linux/arm64")

# 测试函数
test_image() {
    log_info "开始测试GDAL OpenJDK多架构镜像..."
    
    # 创建数据和工作目录
    mkdir -p data workspace
    
    # 使用docker-compose启动服务
    log_info "启动GDAL OpenJDK容器..."
    docker-compose -f docker-compose-openjdk.yml up -d
    
    # 等待容器启动
    sleep 10
    
    # 检查容器状态
    if docker-compose -f docker-compose-openjdk.yml ps | grep -q "running"; then
        log_success "容器运行正常"
    else
        log_error "容器启动失败"
        docker-compose -f docker-compose-openjdk.yml logs
        exit 1
    fi
    
    # 编译测试程序
    log_info "编译Java测试程序..."
    docker-compose -f docker-compose-openjdk.yml exec -T gdal-openjdk javac -cp /usr/local/share/java/gdal.jar /workspace/GdalOpenJdkTest.java
    
    if [ $? -eq 0 ]; then
        log_success "Java测试程序编译成功"
    else
        log_error "Java测试程序编译失败"
        exit 1
    fi
    
    # 运行测试程序
    log_info "运行Java测试程序..."
    docker-compose -f docker-compose-openjdk.yml exec -T gdal-openjdk java -cp /workspace:/usr/local/share/java/gdal.jar -Djava.library.path=/usr/local/lib GdalOpenJdkTest
    
    if [ $? -eq 0 ]; then
        log_success "Java测试程序运行成功"
    else
        log_error "Java测试程序运行失败"
        exit 1
    fi
    
    # 检查GDAL版本
    log_info "检查GDAL版本..."
    GDAL_VERSION_OUTPUT=$(docker-compose -f docker-compose-openjdk.yml exec -T gdal-openjdk gdalinfo --version)
    echo "$GDAL_VERSION_OUTPUT"
    
    if echo "$GDAL_VERSION_OUTPUT" | grep -q "3.7.1"; then
        log_success "GDAL版本正确 (3.7.1)"
    else
        log_error "GDAL版本不正确"
        exit 1
    fi
    
    # 检查Java版本
    log_info "检查Java版本..."
    JAVA_VERSION_OUTPUT=$(docker-compose -f docker-compose-openjdk.yml exec -T gdal-openjdk java -version 2>&1)
    echo "$JAVA_VERSION_OUTPUT"
    
    if echo "$JAVA_VERSION_OUTPUT" | grep -q "1.8.0_342"; then
        log_success "Java版本正确 (1.8.0_342)"
    else
        log_error "Java版本不正确"
        exit 1
    fi
    
    # 测试关键驱动
    log_info "测试关键驱动..."
    docker-compose -f docker-compose-openjdk.yml exec -T gdal-openjdk bash -c 'gdalinfo --formats | grep -E "(GTiff|PNG|JPEG|HDF5|HDF4|netCDF)"'
    
    if [ $? -eq 0 ]; then
        log_success "关键驱动可用"
    else
        log_warning "部分关键驱动可能不可用"
    fi
    
    # 清理
    log_info "停止并清理容器..."
    docker-compose -f docker-compose-openjdk.yml down
    
    # 多架构测试
    test_multi_arch
    
    log_success "GDAL OpenJDK镜像测试完成！"
}

# 多架构测试函数
test_multi_arch() {
    log_info "开始多架构测试..."
    
    for platform in "${TEST_PLATFORMS[@]}"; do
        log_info "测试平台: $platform"
        
        # 构建特定平台的镜像
        log_info "构建 $platform 平台镜像..."
        docker buildx build --platform $platform -t gdal-openjdk:test-$platform -f Dockerfile_openjdk .
        
        # 运行特定平台的容器进行测试
        log_info "运行 $platform 平台测试..."
        docker run --rm --platform $platform gdal-openjdk:test-$platform gdalinfo --version
        
        if [ $? -eq 0 ]; then
            log_success "$platform 平台测试通过"
        else
            log_error "$platform 平台测试失败"
            exit 1
        fi
        
        # 清理测试镜像
        docker rmi gdal-openjdk:test-$platform
    done
    
    log_success "多架构测试完成！"
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
    test_image
}

# 执行主函数
main "$@"