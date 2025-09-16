# GDAL JDK8 GDAL2.4.0镜像使用指南

## 概述

本镜像基于OpenJDK 8u342构建，集成了GDAL 2.4.0地理空间数据处理库，包含完整的GEOS、PROJ、JPEG、HDF5、HDF4和NetCDF支持，并提供了Java绑定。

## 镜像特性

- **多架构支持**: 支持AMD64和ARM64架构
- **完整GDAL环境**: 包含GDAL 2.4.0核心库、工具和Java绑定
- **多格式支持**: 支持GEOS、PROJ、JPEG、HDF5、HDF4、NetCDF等库
- **Java集成**: 集成OpenJDK 8u342运行环境和GDAL Java绑定
- **生产就绪**: 包含健康检查配置

## 快速开始

### 1. 构建镜像

```bash
# 给构建脚本添加执行权限
chmod +x build-jdk8-gdal240.sh

# 基本构建（多架构）
./build-jdk8-gdal240.sh

# 使用自定义标签构建
./build-jdk8-gdal240.sh --tag v1.0.0

# 只构建特定架构
./build-jdk8-gdal240.sh --platforms linux/amd64
```

### 2. 拉取镜像（如果已推送到仓库）

```bash
# 拉取最新版本
docker pull your-registry.com/gdal-jdk8-gdal240:2.4.0-jdk8
```

### 3. 基本运行

```bash
# 交互式运行
docker run -it --rm gdal-jdk8-gdal240:2.4.0-jdk8

# 挂载数据目录运行
docker run -it --rm \
  -v $(pwd)/data:/data \
  gdal-jdk8-gdal240:2.4.0-jdk8
```

## 快速测试

在容器中运行提供的测试程序：

```bash
# 编译测试程序
javac -cp /usr/local/share/java/gdal.jar GdalJdk8Gdal240Test.java

# 运行测试
java -cp .:/usr/local/share/java/gdal.jar -Djava.library.path=/usr/local/lib GdalJdk8Gdal240Test
```

## 支持的格式

### 栅格格式
- GeoTIFF (.tif, .tiff)
- PNG (.png)
- JPEG (.jpg, .jpeg)
- NetCDF (.nc)
- HDF5 (.h5, .hdf5)
- HDF4 (.hdf)
- 以及更多...

### 矢量格式
- Shapefile (.shp)
- GeoJSON (.geojson)
- 以及更多...

## 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `GDAL_VERSION` | `2.4.0` | GDAL版本号 |
| `GDAL_DATA` | `/usr/local/share/gdal` | GDAL数据文件路径 |
| `JAVA_HOME` | `/usr/local/openjdk-8` | Java安装路径 |
| `CLASSPATH` | `/usr/local/share/java/gdal.jar` | Java类路径（包含GDAL JAR） |

## 多架构支持

本镜像支持以下架构：
- `linux/amd64` - Intel/AMD 64位架构
- `linux/arm64` - ARM 64位架构

### 构建特定架构

```bash
# 构建AMD64架构
./build-jdk8-gdal240.sh --platforms linux/amd64

# 构建ARM64架构
./build-jdk8-gdal240.sh --platforms linux/arm64

# 构建多架构
./build-jdk8-gdal240.sh --platforms linux/amd64,linux/arm64
```

### 运行特定架构

```bash
# 运行AMD64架构
docker run --platform linux/amd64 -it --rm gdal-jdk8-gdal240:2.4.0-jdk8

# 运行ARM64架构
docker run --platform linux/arm64 -it --rm gdal-jdk8-gdal240:2.4.0-jdk8
```

## Java应用示例

### 1. 验证Java环境和GDAL绑定

```bash
# 检查Java版本
java -version

# 检查GDAL版本
gdalinfo --version

# 验证GDAL Java绑定
ls -la /usr/local/share/java/gdal.jar
ls -la /usr/local/lib/*gdal*
```

### 2. 运行Java应用示例

```bash
# 编译测试程序
javac -cp /usr/local/share/java/gdal.jar GdalJdk8Gdal240Test.java

# 运行测试程序
java -cp .:/usr/local/share/java/gdal.jar -Djava.library.path=/usr/local/lib GdalJdk8Gdal240Test
```

## 构建自定义镜像

### 扩展基础镜像

```dockerfile
FROM gdal-jdk8-gdal240:2.4.0-jdk8

# 安装额外的包
USER root
RUN apt-get update && apt-get install -y your-package

# 切换回普通用户
USER gdaluser

# 设置自定义环境变量
ENV YOUR_VAR=value
```

## 版本信息

- **GDAL版本**: 2.4.0（从源代码编译）
- **Java版本**: OpenJDK 8u342
- **支持库**: GEOS, PROJ, JPEG, HDF5, HDF4, NetCDF
- **镜像版本**: 1.0.0
- **支持架构**: AMD64, ARM64

## 许可证

本镜像遵循相关组件的许可证：
- GDAL 2.4.0: MIT/X许可证
- OpenJDK 8u342: GPL v2 with Classpath Exception