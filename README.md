# Docker镜像集合

本仓库包含各种用途的Docker镜像构建文件，支持多架构部署和生产环境使用。

## 项目概述

该项目致力于提供高质量、安全、多架构支持的Docker镜像，涵盖地理空间数据处理、Java应用开发等多个领域。所有镜像都基于最佳实践构建，包含完整的文档和使用示例。

## 镜像列表

### GDAL多架构镜像

基于Alpine Linux的轻量级GDAL（地理空间数据抽象库）镜像，集成Oracle JDK 8运行环境。

**特性:**
- 🏗️ 多架构支持 (AMD64, ARM64)
- 🐧 基于Alpine Linux，镜像体积小
- 🗺️ GDAL 3.7.1地理空间数据处理能力
- ☕ 集成Oracle JDK 8兼容运行环境（Zulu JDK）
- 🚀 **Java专用**: 不包含Python支持，保持轻量化
- 🔒 安全设计，非root用户运行
- 📊 包含健康检查和资源限制

**快速开始:**
```bash
# 进入GDAL目录
cd gdal

# 构建镜像
./build.sh

# 或使用docker-compose
docker-compose up -d
```

[查看详细文档](./gdal/README.md)

### GDAL OpenJDK镜像

基于OpenJDK 8u342的GDAL（地理空间数据抽象库）镜像，包含完整的GEOS、PROJ、JPEG、HDF5、HDF4和NetCDF支持。

**特性:**
- 🏗️ 多架构支持 (AMD64, ARM64)
- 🐧 基于Ubuntu，功能完整
- 🗺️ GDAL 3.7.1地理空间数据处理能力
- ☕ 集成OpenJDK 8u342运行环境
- 📚 包含GEOS、PROJ、JPEG、HDF5、HDF4、NetCDF库支持
- 🚀 Java绑定完整支持
- 🔒 安全设计，非root用户运行
- 📊 包含健康检查

**快速开始:**
```bash
# 进入GDAL目录
cd gdal

# 构建镜像（多架构）
./build-openjdk.sh

# 或使用docker-compose
docker-compose -f docker-compose-openjdk.yml up -d
```

[查看详细文档](./gdal/README_OPENJDK.md)

## 🚀 CI/CD 自动化

本项目使用GitHub Actions实现完整的CI/CD流程，支持多架构构建和多环境部署。

### 📋 主要特性

- ✅ **多架构构建**: 自动构建AMD64和ARM64架构镜像
- 🔄 **自动化部署**: 支持开发/预发布/生产环境自动部署
- 📦 **版本管理**: 自动化版本发布和标签管理
- 🚀 **性能优化**: 智能缓存和构建加速
- 🔒 **安全扫描**: 自动漏洞检测和安全验证

### 🏷️ 镜像标签

| 标签 | 说明 | 更新频率 |
|------|------|----------|
| `latest` | 最新稳定版 | 主分支推送时 |
| `dev` | 开发版本 | 开发分支推送时 |
| `v1.2.3` | 具体版本 | 标签发布时 |
| `stable` | 稳定版本 | 正式发布时 |

### 🚀 快速使用

```bash
# 拉取最新稳定版
docker pull ghcr.io/your-username/dockerfile/gdal-multi-arch:latest

# 拉取开发版
docker pull ghcr.io/your-username/dockerfile/gdal-multi-arch:dev

# 拉取特定版本
docker pull ghcr.io/your-username/dockerfile/gdal-multi-arch:v1.0.0
```

### 📚 详细文档

查看 [CI/CD配置指南](CI-CD.md) 了解完整的自动化流程。

## ⚙️ 通用特性

- ✅ **多架构支持**: 所有镜像支持AMD64和ARM64架构
- 🔧 **自动化构建**: 提供完整的构建脚本和CI/CD配置
- 📚 **详细文档**: 每个镜像都包含完整的使用文档和示例
- 🛡️ **安全最佳实践**: 遵循Docker安全最佳实践
- 🚀 **生产就绪**: 包含健康检查、资源限制等生产环境配置

## 快速开始

### 环境要求

- Docker 20.10+
- Docker Buildx（多架构构建支持）
- Docker Compose 2.0+（可选）

### 构建镜像

每个镜像目录都包含独立的构建脚本：

```bash
# 进入具体镜像目录
cd <image-directory>

# 查看构建选项
./build.sh --help

# 基本构建
./build.sh

# 构建并推送到仓库
./build.sh --push --registry your-registry.com
```

### 使用Docker Compose

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 项目结构

```
dockerfile/
├── README.md                 # 项目主文档
├── gdal/                     # GDAL多架构镜像
│   ├── Dockerfile           # GDAL镜像构建文件
│   ├── Dockerfile_openjdk   # GDAL OpenJDK镜像构建文件
│   ├── docker-compose.yml   # 服务编排配置
│   ├── docker-compose-openjdk.yml   # OpenJDK服务编排配置
│   ├── build.sh            # 多架构构建脚本
│   ├── build-openjdk.sh    # OpenJDK多架构构建脚本
│   └── README.md           # GDAL镜像详细文档
└── [其他镜像目录]...
```

## 开发指南

### 添加新镜像

1. 创建新的镜像目录
2. 编写Dockerfile
3. 创建构建脚本（可参考现有的build.sh）
4. 添加docker-compose.yml配置
5. 编写详细的README.md文档
6. 更新主README.md

### 构建最佳实践

- 使用多阶段构建减少镜像大小
- 合并RUN命令减少镜像层数
- 及时清理包管理器缓存
- 使用非root用户运行
- 添加健康检查
- 设置合理的资源限制

### 文档要求

每个镜像都应包含：
- 详细的使用说明
- 环境变量配置
- 卷挂载示例
- 常用命令示例
- 故障排除指南
- 最佳实践建议

## 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

1. Fork项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

### 贡献类型

- 🐛 Bug修复
- ✨ 新功能添加
- 📚 文档改进
- 🎨 代码格式优化
- ⚡ 性能改进
- 🔒 安全修复

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

各镜像中包含的软件组件遵循其各自的许可证。

## 支持

如果您遇到问题或有任何建议：

- 📖 首先查看相关文档
- 🐛 在GitHub Issues中搜索现有问题
- 💡 提交新的Issue或建议
- 🤝 参与社区讨论

## 更新日志

### v1.0.0 (2025-09-10)
- 🎉 初始版本发布
- ✅ GDAL多架构镜像支持
- 📚 完整文档和使用指南
- 🔧 自动化构建脚本

### v1.1.0 (2025-09-12)
- 🎉 新增GDAL OpenJDK镜像支持
- ✅ 基于OpenJDK 8u342的GDAL 3.7.1镜像
- 📚 包含GEOS、PROJ、JPEG、HDF5、HDF4、NetCDF库支持
- 🔧 提供GitHub Actions自动化构建
- 🏗️ 支持多架构（AMD64/ARM64）构建

---

**Made with ❤️ for the community**