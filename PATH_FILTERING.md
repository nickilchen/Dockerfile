# GitHub Actions路径过滤配置指南

## 概述

本文档说明了项目中各个GitHub Actions工作流的路径过滤配置，确保只有相关文件变动才会触发工作流更新，提高构建效率并减少不必要的资源消耗。

## GDAL JDK8 GDAL2.4.0工作流

**工作流文件**: `.github/workflows/docker-build-jdk8-gdal240.yml`

### 触发路径

```yaml
paths:
  # 核心构建文件
  - 'gdal/Dockerfile_jdk8_gdal240'
  - 'gdal/build-jdk8-gdal240.sh'
  # 测试文件
  - 'gdal/GdalJdk8Gdal240Test.java'
  - 'gdal/SimpleGdalTest.java'
  # 配置文件
  - 'gdal/docker-compose-jdk8-gdal240.yml'
  - 'gdal/test-gdal240-build.sh'
  # 工作流文件
  - '.github/workflows/docker-build-jdk8-gdal240.yml'
  # README文档
  - 'gdal/README_JDK8_GDAL240.md'
```

## GDAL OpenJDK工作流

**工作流文件**: `.github/workflows/docker-build-openjdk.yml`

### 触发路径

```yaml
paths:
  # 核心构建文件
  - 'gdal/Dockerfile_openjdk'
  - 'gdal/build-openjdk.sh'
  # 测试文件
  - 'gdal/GdalOpenJdkTest.java'
  # 配置文件
  - 'gdal/docker-compose-openjdk.yml'
  - 'gdal/docker-compose-test-openjdk-multi-arch.yml'
  - 'gdal/test-openjdk.sh'
  - 'gdal/test-openjdk-multi-arch.sh'
  # 工作流文件
  - '.github/workflows/docker-build-openjdk.yml'
  # README文档
  - 'gdal/README_OPENJDK.md'
```

## PostGIS工作流

**工作流文件**: `.github/workflows/docker-build-postgis.yml`

### 触发路径

```yaml
paths:
  # PostGIS核心文件
  - 'postgis/**/Dockerfile'
  - 'postgis/**/alpine/Dockerfile'
  - 'postgis/**/initdb-postgis.sh'
  - 'postgis/**/update-postgis.sh'
  # 构建和测试脚本
  - 'postgis/build.sh'
  - 'postgis/test.sh'
  - 'postgis/list-versions.sh'
  - 'postgis/verify-build-system.sh'
  # 配置文件
  - 'postgis/docker-compose.yml'
  # 工作流文件
  - '.github/workflows/docker-build-postgis.yml'
  # README文档
  - 'postgis/README.md'
```

## 路径过滤最佳实践

### 1. 精确匹配
- 只包含直接影响构建的文件
- 避免过于宽泛的路径匹配（如`gdal/*`）

### 2. 分类组织
- 核心构建文件（Dockerfile, 构建脚本）
- 测试文件（Java测试程序）
- 配置文件（docker-compose, 测试脚本）
- 文档文件（README）
- 工作流文件（自身）

### 3. 使用通配符
- 对于有规律的文件结构，使用通配符减少重复
- 例如：`postgis/**/Dockerfile`匹配所有版本的Dockerfile

### 4. 定期审查
- 当添加新文件时，评估是否需要添加到路径过滤器
- 移除不再使用的文件路径

## 维护指南

### 添加新文件到路径过滤器
1. 确定文件是否直接影响镜像构建
2. 将文件路径添加到相应的push和pull_request路径中
3. 验证路径过滤器是否正常工作

### 移除文件路径
1. 确认文件不再影响镜像构建
2. 从路径过滤器中移除相关路径
3. 验证工作流仍然正常工作

## 故障排除

### 工作流未按预期触发
1. 检查修改的文件是否在路径过滤器中
2. 验证路径语法是否正确
3. 查看GitHub Actions日志确认路径匹配情况

### 工作流触发过于频繁
1. 检查路径过滤器是否过于宽泛
2. 移除不必要的路径匹配
3. 考虑是否需要按文件类型进一步细分