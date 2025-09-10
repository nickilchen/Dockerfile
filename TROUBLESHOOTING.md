# 🔧 Docker 镜像名称大小写问题修复

## 问题描述

在使用GitHub Actions构建多架构Docker镜像时，遇到以下错误：

```
ERROR: failed to build: invalid tag "ghcr.io/nickilchen/Dockerfile/gdal-multi-arch:latest": repository name must be lowercase
```

## 问题原因

Docker镜像标签的仓库名称必须全部为小写字母，但是我们的配置中使用了：

```yaml
IMAGE_NAME: ${{ github.repository }}/gdal-multi-arch
```

其中 `github.repository` 返回的是 `nickilchen/Dockerfile`，包含大写字母 "Dockerfile"，违反了Docker的命名规范。

## 解决方案

### 1. 修复主构建工作流 (.github/workflows/docker-build.yml)

在构建配置步骤中添加小写转换：

```yaml
# 确定标签时添加小写转换
IMAGE_NAME_LOWER=$(echo "${{ env.IMAGE_NAME }}" | tr '[:upper:]' '[:lower:]')

# 在标签生成中使用小写镜像名
TAGS="${{ env.REGISTRY }}/$IMAGE_NAME_LOWER:latest${TAG_SUFFIX}"

# 在输出配置中使用小写镜像名
echo "image-name=$IMAGE_NAME_LOWER" >> $GITHUB_OUTPUT
```

### 2. 修复发布工作流 (.github/workflows/release.yml)

在发布元数据提取步骤中：

```yaml
# 确保镜像名称小写
IMAGE_NAME_LOWER=$(echo "${{ env.IMAGE_NAME }}" | tr '[:upper:]' '[:lower:]')

# 构建标签列表
TAGS="${{ env.REGISTRY }}/$IMAGE_NAME_LOWER:${VERSION}"
```

### 3. 修复部署工作流 (.github/workflows/deployment.yml)

在部署配置步骤中：

```yaml
# 设置注册表URL（确保小写）
IMAGE_NAME_LOWER=$(echo "${{ env.IMAGE_NAME }}" | tr '[:upper:]' '[:lower:]')
REGISTRY_URL="${{ env.REGISTRY }}/$IMAGE_NAME_LOWER:${IMAGE_TAG}"
```

## 修复后的镜像标签

修复后，Docker镜像标签将变为：

- 原来：`ghcr.io/nickilchen/Dockerfile/gdal-multi-arch:latest` ❌
- 修复后：`ghcr.io/nickilchen/dockerfile/gdal-multi-arch:latest` ✅

## 验证修复

所有工作流文件已通过语法检查，修复完成后：

- ✅ docker-build.yml - 主构建工作流
- ✅ release.yml - 版本管理工作流  
- ✅ deployment.yml - 多环境部署工作流
- ✅ cache-management.yml - 无需修改

## 最佳实践

为避免类似问题，建议：

1. **始终将镜像名称转换为小写**：
   ```bash
   IMAGE_NAME_LOWER=$(echo "$IMAGE_NAME" | tr '[:upper:]' '[:lower:]')
   ```

2. **使用明确的仓库名称**：
   ```yaml
   # 推荐方式
   IMAGE_NAME: your-username/gdal-multi-arch
   
   # 避免直接使用 github.repository（可能包含大写字母）
   IMAGE_NAME: ${{ github.repository }}/gdal-multi-arch
   ```

3. **在CI/CD管道中添加验证**：
   ```bash
   # 验证镜像名称格式
   if [[ ! "$IMAGE_NAME" =~ ^[a-z0-9/_.-]+$ ]]; then
     echo "Error: Image name contains invalid characters"
     exit 1
   fi
   ```

## 相关文档

- [Docker官方命名规范](https://docs.docker.com/engine/reference/commandline/tag/#description)
- [GitHub Container Registry文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

# 🔧 GDAL编译linux/fs.h头文件缺失问题修复

## 问题描述

在构建GDAL 3.7.1镜像时，遇到以下CMake配置错误：

```
CMake Error at port/CMakeLists.txt:146 (message):
  linux/fs.h header not found.  Impact will be lack of sparse file detection.
  Define the ACCEPT_MISSING_LINUX_FS_HEADER:BOOL=ON CMake variable if you
  want to build despite this limitation.
```

## 问题原因

Alpine Linux基础镜像默认不包含Linux内核头文件，导致GDAL编译时无法找到`linux/fs.h`头文件。这个文件用于稀疏文件检测功能。

## 解决方案

### 1. 安装Linux内核头文件包

在Dockerfile的系统依赖安装步骤中添加：

```dockerfile
# Linux内核头文件（解决linux/fs.h问题）
linux-headers \
```

### 2. 配置CMake接受缺失的头文件

在GDAL编译的CMake配置中添加：

```dockerfile
cmake .. \
    # ... 其他配置项 ... \
    -DACCEPT_MISSING_LINUX_FS_HEADER:BOOL=ON && \
```

### 3. 完整修复的Dockerfile片段

```dockerfile
# 安装系统依赖和构建工具
RUN apk update && \
    apk add --no-cache \
        # ... 其他依赖 ... \
        # Linux内核头文件（解决linux/fs.h问题）
        linux-headers \
        # ... 更多依赖 ... \
    && rm -rf /var/cache/apk/*

# 编译安装GDAL 3.7.1
RUN cd /tmp && \
    # ... 下载和解压步骤 ... \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        # ... 其他配置项 ... \
        -DACCEPT_MISSING_LINUX_FS_HEADER:BOOL=ON && \
    # ... 编译和安装步骤 ...
```

## 影响说明

使用`-DACCEPT_MISSING_LINUX_FS_HEADER:BOOL=ON`配置项后：

- ✅ GDAL编译可以正常进行
- ⚠️ 稀疏文件检测功能将不可用
- ✅ 其他GDAL功能不受影响
- ✅ Java绑定正常工作

对于大多数地理空间数据处理用例，稀疏文件检测功能的缺失不会造成显著影响。

## 验证修复

修复应用后，重新构建镜像：

```bash
# 清理旧镜像和缓存
docker system prune -af

# 重新构建
docker build -t gdal-multi-arch:latest .

# 或使用构建脚本
./build.sh
```

构建成功后，验证GDAL版本：

```bash
docker run --rm gdal-multi-arch:latest gdalinfo --version
# 应输出：GDAL 3.7.1, released 2023/05/10
```

## 相关文档

- [GDAL CMake构建选项](https://gdal.org/development/cmake.html)
- [Alpine Linux包管理](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper)

---

# 🔧 GDAL Java绑定构建ant依赖缺失问题修复

## 问题描述

在构建GDAL Java绑定时，遇到以下CMake配置错误：

```
CMake Error at swig/CMakeLists.txt:53 (message):
  ant is a requirement to build the Java bindings
```

## 问题原因

GDAL构建Java绑定时需要Apache Ant工具来编译Java代码，但Alpine基础镜像中没有预装ant，导致CMake配置失败。

## 解决方案

### 在Dockerfile中添加Apache Ant依赖

在系统依赖安装步骤中添加`apache-ant`包：

```dockerfile
# 安装系统依赖和构建工具
RUN apk update && \
    apk add --no-cache \
        # ... 其他依赖 ... \
        # Java开发工具
        swig \
        # Apache Ant（构建Java绑定必需）
        apache-ant \
        # ... 更多依赖 ... \
    && rm -rf /var/cache/apk/*
```

### 验证修复

修复应用后，重新构建镜像：

```bash
# 清理旧镜像和缓存
docker system prune -af

# 重新构建
docker build -t gdal-multi-arch:latest .
```

构建过程中应该能看到：

```
-- Found Java: /opt/java/jdk8/bin/java (found version "1.8.0.412")
-- Found Apache Ant
```

## 相关依赖说明

### Apache Ant的作用

- **Java代码编译**：编译GDAL的Java绑定源代码
- **JAR包生成**：生成`gdal.jar`文件
- **构建自动化**：管理Java项目的构建流程

### 完整的Java绑定构建依赖

```dockerfile
# Java开发环境完整依赖
apk add --no-cache \
    # JDK环境（通过wget安装Zulu JDK）
    # SWIG（生成绑定代码）
    swig \
    # Apache Ant（编译Java代码）
    apache-ant
```

## 影响说明

添加Apache Ant后：

- ✅ GDAL Java绑定能够正常构建
- ✅ 生成完整的`gdal.jar`和native库文件
- ✅ Java应用可以正常使用GDAL功能
- ⚠️ 镜像大小略有增加（约10-15MB）

## 相关文档

- [Apache Ant官方文档](https://ant.apache.org/)
- [GDAL Java绑定构建说明](https://gdal.org/api/java/)

---

修复日期：2025-09-10
修复版本：Dockerfile v1.0.3

---

修复日期：2025-09-10
修复版本：所有工作流文件 v1.0.1，Dockerfile v1.0.2