#!/bin/bash

# 列出所有可用的PostGIS版本

echo "可用的PostGIS版本:"
echo "=================="
echo "PostgreSQL | PostGIS  | 架构支持"
echo "----------|----------|----------"

# 查找所有PostGIS版本目录并显示信息
find postgis -maxdepth 2 -type d -name "*-*" | sort | while read dir; do
    if [[ $dir =~ postgis/([0-9]+)-([0-9.]+) ]]; then
        PG_VERSION="${BASH_REMATCH[1]}"
        POSTGIS_VERSION="${BASH_REMATCH[2]}"
        
        # 检查架构支持
        ARCH_SUPPORT="未知"
        if [ -d "$dir/alpine" ]; then
            ARCH_SUPPORT="AMD64, ARM64"
        fi
        
        printf "%-10s|%-10s| %s\n" "$PG_VERSION" "$POSTGIS_VERSION" "$ARCH_SUPPORT"
    fi
done

echo ""
echo "使用方法:"
echo "  构建特定版本: ./build.sh --postgres-version <PG版本> --postgis-version <PostGIS版本>"
echo "  例如: ./build.sh --postgres-version 13 --postgis-version 3.5"