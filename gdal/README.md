# GDAL多架构镜像使用指南

## 概述

本镜像基于Alpine Linux构建，集成了GDAL 3.7.1（Geospatial Data Abstraction Library）地理空间数据处理库和Oracle JDK 8兼容运行环境，支持多架构部署（AMD64、ARM64）。

**重要说明：本镜像专注于Java集成，不包含Python GDAL绑定。**

## 镜像特性

- **轻量级基础**: 基于Alpine Linux，镜像体积小
- **多架构支持**: 支持AMD64和ARM64架构
- **完整GDAL环境**: 包含GDAL 3.7.1核心库、工具和Java绑定（不包含Python）
- **Java支持**: 集成Oracle JDK 8兼容运行环境（Zulu JDK）
- **安全设计**: 使用非root用户运行，遵循安全最佳实践
- **生产就绪**: 包含健康检查和资源限制配置
- **Java专用**: 不包含Python支持，保持镜像轻量化

## 快速开始

### 1. 拉取镜像

```bash
# 拉取最新版本
docker pull gdal-multi-arch:latest

# 或者从指定仓库拉取
docker pull your-registry.com/gdal-multi-arch:latest
```

### 2. 基本运行

```bash
# 交互式运行
docker run -it --rm gdal-multi-arch:latest

# 挂载数据目录运行
docker run -it --rm \
  -v $(pwd)/data:/data \
  gdal-multi-arch:latest
```

## 快速测试

在容器中运行提供的测试程序：

```bash
# 进入容器
docker-compose exec gdal bash

# 编译测试程序
javac -cp /usr/share/java/gdal.jar /workspace/GdalTest.java

# 运行测试
java -cp /workspace:/usr/share/java/gdal.jar -Djava.library.path=/usr/lib GdalTest
```

## 详细使用说明

### 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `GDAL_VERSION` | `3.7.1` | GDAL版本号 |
| `GDAL_DATA` | `/usr/share/gdal` | GDAL数据文件路径 |
| `JAVA_HOME` | `/opt/java/jdk8` | Java安装路径 |
| `CLASSPATH` | `/usr/share/java/gdal.jar` | Java类路径（包含GDAL JAR） |
| `GDAL_CACHEMAX` | `256` | GDAL缓存大小（MB） |
| `GDAL_NUM_THREADS` | `ALL_CPUS` | GDAL使用的线程数 |

### 卷挂载

推荐的卷挂载配置：

```bash
docker run -it --rm \
  -v $(pwd)/data:/data:rw \           # 数据输入输出目录
  -v $(pwd)/workspace:/workspace:rw \ # 工作空间
  -v $(pwd)/scripts:/scripts:ro \     # 脚本目录（只读）
  gdal-multi-arch:latest
```

### 常用GDAL命令示例

#### 1. 查看数据信息

```bash
# 查看栅格数据信息
gdalinfo /data/input.tif

# 查看矢量数据信息
ogrinfo /data/input.shp
```

#### 2. 格式转换

```bash
# 栅格格式转换（TIFF到PNG）
gdal_translate -of PNG /data/input.tif /data/output.png

# 矢量格式转换（Shapefile到GeoJSON）
ogr2ogr -f GeoJSON /data/output.geojson /data/input.shp
```

#### 3. 投影变换

```bash
# 栅格投影变换
gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3857 \
  /data/input.tif /data/output_projected.tif

# 矢量投影变换
ogr2ogr -s_srs EPSG:4326 -t_srs EPSG:3857 \
  /data/output_projected.shp /data/input.shp
```

#### 4. 数据处理

```bash
# 创建金字塔
gdaladdo -r average /data/input.tif 2 4 8 16

# 栅格重采样
gdalwarp -tr 30 30 -r bilinear \
  /data/input.tif /data/resampled.tif

# 栅格裁剪
gdalwarp -cutline /data/boundary.shp -crop_to_cutline \
  /data/input.tif /data/clipped.tif
```

### Java应用示例

#### 1. 验证Java环境和GDAL绑定

```bash
# 检查Java版本（应显示1.8.x版本）
java -version

# 检查Java编译器
javac -version

# 查看Java环境变量
echo $JAVA_HOME
echo $CLASSPATH

# 检查GDAL版本（应显示3.7.1）
gdalinfo --version

# 验证GDAL Java绑定
ls -la /usr/share/java/gdal.jar
ls -la /usr/lib/*gdal*
```

#### 2. 运行Java应用示例

```bash
# 编译测试程序
javac -cp /usr/share/java/gdal.jar /workspace/GdalTest.java

# 运行测试程序
java -cp /workspace:/usr/share/java/gdal.jar -Djava.library.path=/usr/lib GdalTest

# 或者使用环境变量
java -cp $CLASSPATH:/workspace -Djava.library.path=/usr/lib GdalTest
```

#### 3. 完整的Java GDAL使用示例

以下是一个完整的Java程序示例，演示如何使用GDAL Java绑定：

```java
import org.gdal.gdal.gdal;
import org.gdal.gdal.Dataset;
import org.gdal.gdalconst.gdalconst;

public class SimpleGdalExample {
    static {
        // 初始GDAL
        gdal.AllRegister();
    }
    
    public static void main(String[] args) {
        // 显示GDAL版本
        System.out.println("GDAL版本: " + gdal.VersionInfo("RELEASE_NAME"));
        
        // 创建内存数据集
        var driver = gdal.GetDriverByName("MEM");
        Dataset dataset = driver.Create("", 256, 256, 1, gdalconst.GDT_Byte);
        
        if (dataset != null) {
            System.out.println("数据集创建成功");
            System.out.println("宽度: " + dataset.getRasterXSize());
            System.out.println("高度: " + dataset.getRasterYSize());
            dataset.delete();
        }
    }
}
```

编译和运行：
```bash
# 编译
javac -cp /usr/share/java/gdal.jar SimpleGdalExample.java

# 运行
java -cp .:/usr/share/java/gdal.jar -Djava.library.path=/usr/lib SimpleGdalExample
```

## 高级配置

### 1. 性能优化

```yaml
# docker-compose.yml中的性能配置
services:
  gdal:
    environment:
      - GDAL_VERSION=3.7.1
      - GDAL_CACHEMAX=1024              # 增加缓存
      - GDAL_NUM_THREADS=ALL_CPUS       # 使用所有CPU
      - GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR
    deploy:
      resources:
        limits:
          memory: 4G                    # 内存限制
          cpus: '4.0'                   # CPU限制
```

### 2. 网络配置

```bash
# 自定义网络运行
docker network create gdal-network
docker run -it --rm \
  --network gdal-network \
  --name gdal-worker \
  gdal-multi-arch:latest
```

### 3. 安全配置

```bash
# 使用只读根文件系统
docker run -it --rm \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /workspace \
  -v $(pwd)/data:/data \
  gdal-multi-arch:latest
```

## 构建自定义镜像

### 1. 扩展基础镜像

```dockerfile
FROM gdal-multi-arch:latest

# 安装额外的包
USER root
RUN apk add --no-cache your-package

# 切换回普通用户
USER gdaluser

# 设置自定义环境变量
ENV YOUR_VAR=value
```

### 2. 使用构建脚本

```bash
# 基本构建
./build.sh

# 构建并推送
./build.sh --push --registry your-registry.com

# 自定义标签构建
./build.sh --tag v1.0.0

# 查看构建选项
./build.sh --help
```

## 故障排除

### 1. 常见问题

**问题**: 权限拒绝错误
```bash
# 解决方案：检查文件权限
ls -la /data
chmod 755 /data
```

**问题**: GDAL找不到数据文件
```bash
# 解决方案：检查GDAL_DATA环境变量
echo $GDAL_DATA
ls -la $GDAL_DATA
```

**问题**: Java应用无法运行
```bash
# 解决方案：检查Java环境
echo $JAVA_HOME
java -version
# 确保Java版本为1.8.x
```

**问题**: GDAL版本不正确
```bash
# 解决方案：验证GDAL版本
gdalinfo --version
# 应显示GDAL 3.7.1
```

### 2. 调试模式

```bash
# 启用详细日志
docker run -it --rm \
  -e CPL_DEBUG=ON \
  -e GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR \
  gdal-multi-arch:latest
```

### 3. 健康检查

```bash
# 检查容器健康状态
docker ps
docker inspect container_name | grep Health
```

## 最佳实践

### 1. 数据管理

- 使用专用的数据卷进行大数据集处理
- 定期清理临时文件和缓存
- 使用适当的文件权限设置

### 2. 性能优化

- 根据数据大小调整GDAL_CACHEMAX
- 使用多线程处理大型数据集
- 合理配置容器资源限制

### 3. 安全考虑

- 避免以root用户运行容器
- 使用只读挂载不需要修改的目录
- 定期更新基础镜像和依赖

### 4. 监控和日志

- 配置适当的健康检查
- 收集和分析容器日志
- 监控资源使用情况

## 支持的格式

### 栅格格式
- GeoTIFF (.tif, .tiff)
- PNG (.png)
- JPEG (.jpg, .jpeg)
- NetCDF (.nc)
- HDF5 (.h5, .hdf5)
- 以及更多...

### 矢量格式
- Shapefile (.shp)
- GeoJSON (.geojson)
- KML (.kml)
- GPS Exchange (.gpx)
- PostGIS数据库
- 以及更多...

## 版本信息

- **GDAL版本**: 3.7.1（从源代码编译）
- **Java版本**: Oracle JDK 8兼容（Zulu JDK 8.0.412）
- **Alpine版本**: 最新稳定版
- **镜像版本**: 1.0.0

## 许可证

本镜像遵循相关组件的许可证：
- GDAL 3.7.1: MIT/X许可证
- Oracle JDK 8兼容（Zulu JDK）: GPL v2 with Classpath Exception
- Alpine Linux: MIT许可证

## 贡献和支持

如有问题或建议，请：
1. 查看本文档的故障排除部分
2. 检查项目的GitHub Issues
3. 提交新的Issue或Pull Request

## 更新日志

### v1.0.0
- 初始版本发布
- 支持AMD64和ARM64架构
- 集成GDAL 3.7.1（从源代码编译）
- 集成Oracle JDK 8兼容运行环境（Zulu JDK）
- 包含完整的使用文档和示例
- 支持Java GDAL绑定