# 最小JDK 8镜像

## 概述

本镜像基于Alpine Linux构建，使用本地提供的JDK 8u431包制作，经过优化以达到最小空间占用。镜像删除了不必要的组件和工具，只保留核心Java运行时环境。

## 镜像特性

- **超小体积**: 基于Alpine Linux，删除了不必要的组件
- **本地JDK**: 使用您提供的jdk-8u431-linux-x64.tar.gz包
- **安全设计**: 使用非root用户运行
- **生产就绪**: 包含健康检查配置

## 快速开始

### 1. 构建镜像

```bash
# 给构建脚本添加执行权限
chmod +x build.sh

# 基本构建
./build.sh

# 使用自定义标签构建
./build.sh --tag v1.0.0
```

### 2. 拉取镜像（如果已推送到仓库）

```bash
# 拉取最新版本
docker pull your-registry.com/minimal-jdk8:8u431-alpine
```

### 3. 基本运行

```bash
# 交互式运行
docker run -it --rm minimal-jdk8:8u431-alpine

# 运行Java程序
docker run -it --rm minimal-jdk8:8u431-alpine java -version
```

## 优化措施

为了达到最小空间占用，我们采取了以下优化措施：

1. **基础镜像选择**: 使用Alpine Linux作为基础镜像
2. **组件清理**: 删除了以下不必要的组件：
   - JDK文档和示例
   - 图形化工具（jconsole, jvisualvm等）
   - JavaFX相关组件
   - 不必要的本地化文件
   - 开发工具（javac, javadoc等，根据需要可选择保留）
3. **多阶段构建**: 使用多阶段构建进一步减小最终镜像大小

## 构建选项

### 标准版本

使用[Dockerfile](file://e:\code\Dockerfile\jdk\Dockerfile)构建包含基本Java工具的镜像：

```bash
# 构建标准版本
docker build -t minimal-jdk8:8u431-alpine .
```

### 优化版本

使用[Dockerfile.optimized](file://e:\code\Dockerfile\jdk\Dockerfile.optimized)构建进一步优化的镜像：

```bash
# 构建优化版本
docker build -f Dockerfile.optimized -t minimal-jdk8:8u431-alpine-optimized .
```

## 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `JAVA_HOME` | `/opt/java/openjdk` | Java安装路径 |
| `PATH` | `$JAVA_HOME/bin:$PATH` | 系统PATH环境变量 |

## 安全特性

- 使用非root用户运行容器
- 删除了不必要的系统工具和库
- 包含健康检查配置

## 测试镜像

使用提供的测试脚本验证镜像功能：

```bash
# 给测试脚本添加执行权限
chmod +x test.sh

# 运行测试
./test.sh
```

## GitHub Actions自动化构建

本项目配置了GitHub Actions工作流来自动化构建和推送镜像。

### 触发方式

1. **手动触发**: 通过GitHub界面手动运行工作流
2. **代码推送**: 推送到main或develop分支时自动触发
3. **标签发布**: 创建标签时自动触发
4. **Pull Request**: 提交PR时触发测试构建

### 构建版本

GitHub Actions会自动构建两个版本：
- **标准版**: 基于[Dockerfile](file://e:\code\Dockerfile\jdk\Dockerfile)
- **优化版**: 基于[Dockerfile.optimized](file://e:\code\Dockerfile\jdk\Dockerfile.optimized)

### 推送仓库

构建的镜像会推送到：
- GitHub Container Registry (GHCR)
- 阿里云镜像仓库

## 构建自定义镜像

### 扩展基础镜像

```dockerfile
FROM minimal-jdk8:8u431-alpine

# 安装额外的包
USER root
RUN apk add --no-cache your-package

# 切换回普通用户
USER javauser

# 设置自定义环境变量
ENV YOUR_VAR=value
```

## 版本信息

- **Java版本**: OpenJDK 8u431
- **基础镜像**: Alpine Linux
- **镜像版本**: 1.0.0

## 许可证

本镜像遵循相关组件的许可证：
- OpenJDK 8u431: GPL v2 with Classpath Exception
- Alpine Linux: MIT许可证

## 镜像大小对比

| 镜像类型 | 大小 | 说明 |
|---------|------|------|
| 官方OpenJDK 8 | ~500MB | 完整版本 |
| 本镜像标准版 | ~200MB | 删除不必要组件 |
| 本镜像优化版 | ~150MB | 多阶段构建优化 |

## 使用场景

- 微服务部署
- 容器化Java应用
- 对镜像大小有严格要求的环境
- 资源受限的部署环境