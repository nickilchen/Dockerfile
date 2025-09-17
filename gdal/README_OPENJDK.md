# GDAL OpenJDK镜像使用指南

## 概述

本镜像基于OpenJDK 8u342构建，集成了GDAL 3.7.1地理空间数据处理库，包含完整的GEOS、PROJ、JPEG、HDF5、HDF4和NetCDF支持，并提供了Java绑定。

## 镜像特性

- **多架构支持**: 支持AMD64和ARM64架构
- **完整GDAL环境**: 包含GDAL 3.7.1核心库、工具和Java绑定
- **多格式支持**: 支持GEOS、PROJ、JPEG、HDF5、HDF4、NetCDF等库
- **Java集成**: 集成OpenJDK 8u342运行环境和GDAL Java绑定
- **生产就绪**: 包含健康检查配置

## 快速开始

### 1. 构建镜像

```bash
# 给构建脚本添加执行权限
chmod +x build-openjdk.sh

# 基本构建（多架构）
./build-openjdk.sh

# 使用自定义标签构建
./build-openjdk.sh --tag v1.0.0

# 只构建特定架构
./build-openjdk.sh --platforms linux/amd64
```

### 2. 拉取镜像（如果已推送到仓库）

```bash
# 拉取最新版本
docker pull your-registry.com/gdal-openjdk:3.7.1-openjdk8u342
```

### 3. 基本运行

```bash
# 交互式运行
docker run -it --rm gdal-openjdk:3.7.1-openjdk8u342

# 挂载数据目录运行
docker run -it --rm \
  -v $(pwd)/data:/data \
  gdal-openjdk:3.7.1-openjdk8u342
```

## 快速测试

在容器中运行提供的测试程序：

```bash
# 编译测试程序
javac -cp /usr/local/share/java/gdal.jar GdalOpenJdkTest.java

# 运行测试
java -cp .:/usr/local/share/java/gdal.jar -Djava.library.path=/usr/local/lib GdalOpenJdkTest
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
| `GDAL_VERSION` | `3.7.1` | GDAL版本号 |
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
./build-openjdk.sh --platforms linux/amd64

# 构建ARM64架构
./build-openjdk.sh --platforms linux/arm64

# 构建多架构
./build-openjdk.sh --platforms linux/amd64,linux/arm64
```

### 运行特定架构

```bash
# 运行AMD64架构
docker run --platform linux/amd64 -it --rm gdal-openjdk:3.7.1-openjdk8u342

# 运行ARM64架构
docker run --platform linux/arm64 -it --rm gdal-openjdk:3.7.1-openjdk8u342
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
javac -cp /usr/local/share/java/gdal.jar GdalOpenJdkTest.java

# 运行测试程序
java -cp .:/usr/local/share/java/gdal.jar -Djava.library.path=/usr/local/lib GdalOpenJdkTest
```

## 构建自定义镜像

### 扩展基础镜像

```
FROM gdal-openjdk:3.7.1-openjdk8u342

# 安装额外的包
USER root
RUN apt-get update && apt-get install -y your-package

# 切换回普通用户
USER gdaluser

# 设置自定义环境变量
ENV YOUR_VAR=value
```

## 版本信息

- **GDAL版本**: 3.7.1（从源代码编译）
- **Java版本**: OpenJDK 8u342
- **支持库**: GEOS, PROJ, JPEG, HDF5, HDF4, NetCDF
- **镜像版本**: 1.0.0
- **支持架构**: AMD64, ARM64

## 许可证

本镜像遵循相关组件的许可证：
- GDAL 3.7.1: MIT/X许可证
- OpenJDK 8u342: GPL v2 with Classpath Exception

## 故障排除

### 下载问题

如果在构建过程中遇到下载问题，请检查以下几点：

1. 确保网络连接正常
2. 验证GDAL源代码URL是否可访问
3. 如果问题持续存在，可以手动下载GDAL 3.7.1源代码包并修改Dockerfile中的URL

### 构建失败

如果构建失败，请尝试以下解决方案：

1. 清理Docker构建缓存：
   ```bash
   docker builder prune
   ```

2. 使用--no-cache选项重新构建：
   ```bash
   ./build-openjdk.sh --no-cache
   ```

3. 检查系统资源是否充足（GDAL构建需要较多内存）

### 多架构运行问题

如果在运行特定架构镜像时遇到"exec format error"错误，请检查以下几点：

1. 确保Docker已正确配置多架构支持：
   ```bash
   docker run --privileged --rm tonistiigi/binfmt --install all
   ```

2. 验证镜像是否包含目标架构：
   ```bash
   docker manifest inspect your-registry.com/gdal-openjdk:3.7.1-openjdk8u342
   ```

3. 使用正确的平台标志运行镜像：
   ```bash
   # 对于ARM64
   docker run --platform linux/arm64 -it --rm your-image:tag
   
   # 对于AMD64
   docker run --platform linux/amd64 -it --rm your-image:tag
   ```

4. 如果在Apple Silicon Mac上运行AMD64镜像，确保已安装Rosetta：
   ```bash
   softwareupdate --install-rosetta
   ```

### Java绑定问题

如果Java绑定无法正常工作，请检查以下几点：

1. 确保CLASSPATH环境变量正确设置：
   ```bash
   echo $CLASSPATH
   ```

2. 验证GDAL Java库文件是否存在：
   ```bash
   ls -la /usr/local/share/java/gdal.jar
   ls -la /usr/local/lib/libgdaljni.so
   ```

3. 检查Java.library.path是否包含GDAL库路径：
   ```bash
   java -cp /usr/local/share/java/gdal.jar -Djava.library.path=/usr/local/lib YourApp
   ```
