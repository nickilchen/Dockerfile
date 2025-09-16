#!/bin/bash

# 测试最小JDK 8镜像脚本

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
test_image() {
    log_info "开始测试最小JDK 8镜像..."
    
    # 检查镜像是否存在
    if ! docker images | grep -q "minimal-jdk8.*8u431-alpine"; then
        log_error "未找到minimal-jdk8:8u431-alpine镜像，请先构建镜像"
        exit 1
    fi
    
    # 测试Java版本
    log_info "测试Java版本..."
    JAVA_VERSION_OUTPUT=$(docker run --rm minimal-jdk8:8u431-alpine java -version 2>&1)
    echo "$JAVA_VERSION_OUTPUT"
    
    if echo "$JAVA_VERSION_OUTPUT" | grep -q "1.8.0_431"; then
        log_success "Java版本正确 (1.8.0_431)"
    else
        log_error "Java版本不正确"
        exit 1
    fi
    
    # 测试基本Java命令
    log_info "测试基本Java命令..."
    docker run --rm minimal-jdk8:8u431-alpine javac -version
    
    if [ $? -eq 0 ]; then
        log_success "javac命令可用"
    else
        log_error "javac命令不可用"
        exit 1
    fi
    
    # 测试Java程序运行
    log_info "测试Java程序运行..."
    
    # 创建一个简单的Java程序
    cat > HelloWorld.java << 'EOF'
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World! Minimal JDK 8 is working!");
    }
}
EOF
    
    # 编译并运行Java程序
    docker run --rm -v "$(pwd)":/workspace -w /workspace minimal-jdk8:8u431-alpine javac HelloWorld.java
    docker run --rm -v "$(pwd)":/workspace -w /workspace minimal-jdk8:8u431-alpine java HelloWorld
    
    # 清理临时文件
    rm -f HelloWorld.java HelloWorld.class
    
    log_success "Java程序运行测试通过"
    
    # 显示镜像大小
    log_info "镜像大小信息:"
    docker images minimal-jdk8:8u431-alpine --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    log_success "最小JDK 8镜像测试完成！"
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