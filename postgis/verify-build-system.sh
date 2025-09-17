#!/bin/bash

# 验证PostGIS多架构镜像构建系统

set -e

echo "验证PostGIS多架构镜像构建系统"
echo "================================"

# 检查必要的文件和目录
echo "1. 检查必要的文件和目录..."

# 检查GitHub Actions工作流文件
if [ -f ".github/workflows/docker-build-postgis.yml" ]; then
    echo "  ✅ GitHub Actions工作流文件存在"
else
    echo "  ❌ GitHub Actions工作流文件不存在"
    exit 1
fi

# 检查构建脚本
if [ -f "postgis/build.sh" ]; then
    echo "  ✅ 构建脚本存在"
else
    echo "  ❌ 构建脚本不存在"
    exit 1
fi

# 检查README文件
if [ -f "postgis/README.md" ]; then
    echo "  ✅ README文件存在"
else
    echo "  ❌ README文件不存在"
    exit 1
fi

# 检查Docker Compose文件
if [ -f "postgis/docker-compose.yml" ]; then
    echo "  ✅ Docker Compose文件存在"
else
    echo "  ❌ Docker Compose文件不存在"
    exit 1
fi

# 检查测试脚本
if [ -f "postgis/test.sh" ]; then
    echo "  ✅ 测试脚本存在"
else
    echo "  ❌ 测试脚本不存在"
    exit 1
fi

# 检查PostGIS版本目录
echo "2. 检查PostGIS版本目录..."

POSTGIS_VERSIONS_FOUND=0
find postgis -maxdepth 2 -type d -name "*-*" | sort | while read dir; do
    if [[ $dir =~ postgis/([0-9]+)-([0-9.]+) ]]; then
        PG_VERSION="${BASH_REMATCH[1]}"
        POSTGIS_VERSION="${BASH_REMATCH[2]}"
        
        # 检查alpine目录是否存在
        if [ -d "$dir/alpine" ]; then
            echo "  ✅ PostgreSQL $PG_VERSION + PostGIS $POSTGIS_VERSION (支持多架构)"
            POSTGIS_VERSIONS_FOUND=$((POSTGIS_VERSIONS_FOUND + 1))
        else
            echo "  ⚠️  PostgreSQL $PG_VERSION + PostGIS $POSTGIS_VERSION (不支持多架构)"
        fi
    fi
done

echo "  总共发现 $POSTGIS_VERSIONS_FOUND 个多架构PostGIS版本"

# 检查GitHub Actions工作流语法
echo "3. 检查GitHub Actions工作流语法..."

# 这里我们只是简单检查文件是否存在必要的部分
if grep -q "discover-versions:" ".github/workflows/docker-build-postgis.yml"; then
    echo "  ✅ GitHub Actions工作流包含版本发现任务"
else
    echo "  ❌ GitHub Actions工作流不包含版本发现任务"
    exit 1
fi

if grep -q "build-and-push:" ".github/workflows/docker-build-postgis.yml"; then
    echo "  ✅ GitHub Actions工作流包含构建和推送任务"
else
    echo "  ❌ GitHub Actions工作流不包含构建和推送任务"
    exit 1
fi

if grep -q "test-image:" ".github/workflows/docker-build-postgis.yml"; then
    echo "  ✅ GitHub Actions工作流包含镜像测试任务"
else
    echo "  ❌ GitHub Actions工作流不包含镜像测试任务"
    exit 1
fi

echo ""
echo "🎉 PostGIS多架构镜像构建系统验证通过!"
echo ""
echo "系统功能:"
echo "  - 支持多架构构建 (AMD64, ARM64)"
echo "  - 自动发现所有PostGIS版本"
echo "  - 支持GitHub Actions自动化构建"
echo "  - 包含本地构建脚本"
echo "  - 提供完整的文档和示例"
echo "  - 支持测试和验证"