# PostGIS多架构镜像使用指南

## 概述

本项目提供PostGIS多架构Docker镜像，支持AMD64和ARM64架构。镜像基于PostgreSQL Alpine版本构建，集成了PostGIS空间数据库扩展。

## 镜像特性

- **多架构支持**: 支持AMD64和ARM64架构
- **多种PostgreSQL版本**: 支持PostgreSQL 13-17版本
- **多种PostGIS版本**: 支持PostGIS 3.5-3.6版本
- **Alpine基础镜像**: 轻量级、安全的基础镜像
- **完整PostGIS扩展**: 包含postgis、postgis_topology、postgis_tiger_geocoder等扩展
- **生产就绪**: 包含健康检查配置

## 可用版本

### PostgreSQL 13
- postgis/postgis:13-3.5
- postgis/postgis:13-3.6

### PostgreSQL 14
- postgis/postgis:14-3.5

### PostgreSQL 15
- postgis/postgis:15-3.5

### PostgreSQL 16
- postgis/postgis:16-3.5

### PostgreSQL 17
- postgis/postgis:17-3.5
- postgis/postgis:17-3.6

## 快速开始

### 1. 拉取镜像

```bash
# 拉取特定版本
docker pull postgis/postgis:13-3.5

# 拉取最新版本
docker pull postgis/postgis:latest
```

### 2. 运行容器

```bash
# 基本运行
docker run -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  postgis/postgis:13-3.5

# 挂载数据卷运行
docker run -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  -v $(pwd)/data:/var/lib/postgresql/data \
  postgis/postgis:13-3.5
```

### 3. 连接数据库

```bash
# 使用psql连接
docker exec -it postgis psql -U myuser -d mydb

# 或者使用外部客户端连接
psql -h localhost -p 5432 -U myuser -d mydb
```

## 多架构支持

本镜像支持以下架构：
- `linux/amd64` - Intel/AMD 64位架构
- `linux/arm64` - ARM 64位架构

### 运行特定架构

```bash
# 运行AMD64架构
docker run --platform linux/amd64 -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  postgis/postgis:13-3.5

# 运行ARM64架构
docker run --platform linux/arm64 -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  postgis/postgis:13-3.5
```

## 构建镜像

### 1. 使用构建脚本

```bash
# 给构建脚本添加执行权限
chmod +x build.sh

# 列出所有可用版本
./build.sh --list

# 基本构建
./build.sh

# 构建特定版本
./build.sh --postgres-version 14 --postgis-version 3.5

# 构建并推送到仓库
./build.sh --push --registry your-registry.com

# 使用自定义标签后缀构建
./build.sh --tag-suffix -dev

# 只构建特定架构
./build.sh --platforms linux/amd64
```

### 2. 手动构建

```bash
# 构建特定版本
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag postgis/postgis:13-3.5 \
  postgis/13-3.5/alpine

# 构建并推送到仓库
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag postgis/postgis:13-3.5 \
  --push \
  postgis/13-3.5/alpine
```

## 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `POSTGRES_PASSWORD` | 无 | PostgreSQL超级用户密码（必需） |
| `POSTGRES_USER` | `postgres` | PostgreSQL超级用户名 |
| `POSTGRES_DB` | `postgres` | 默认数据库名 |
| `POSTGRES_INITDB_ARGS` | 无 | 初始化数据库的额外参数 |
| `POSTGRES_INITDB_WALDIR` | 无 | WAL目录位置 |
| `POSTGRES_HOST_AUTH_METHOD` | `trust` | 认证方法 |

## PostGIS扩展

默认情况下，容器会自动创建以下PostGIS扩展：
- `postgis` - 核心PostGIS扩展
- `postgis_topology` - 拓扑扩展
- `fuzzystrmatch` - 模糊字符串匹配扩展
- `postgis_tiger_geocoder` - TIGER/geocoder扩展

### 验证PostGIS安装

```bash
# 连接到数据库并检查PostGIS版本
docker exec -it postgis psql -U myuser -d mydb -c "SELECT PostGIS_Version();"

# 列出所有已安装的扩展
docker exec -it postgis psql -U myuser -d mydb -c "\dx"
```

## 数据持久化

### 使用数据卷

```bash
# 创建命名卷
docker volume create postgis-data

# 使用命名卷运行
docker run -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v postgis-data:/var/lib/postgresql/data \
  postgis/postgis:13-3.5
```

### 使用绑定挂载

```bash
# 创建数据目录
mkdir -p $(pwd)/data

# 使用绑定挂载运行
docker run -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v $(pwd)/data:/var/lib/postgresql/data \
  postgis/postgis:13-3.5
```

## 备份和恢复

### 备份数据库

```bash
# 备份整个数据库
docker exec -t postgis pg_dumpall -c -U myuser > dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql

# 备份特定数据库
docker exec -t postgis pg_dump -c -U myuser mydb > mydb_dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
```

### 恢复数据库

```bash
# 恢复数据库
cat dump.sql | docker exec -i postgis psql -U myuser -d mydb
```

## 高级配置

### 自定义PostGIS配置

```bash
# 使用自定义配置文件运行
docker run -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v $(pwd)/postgresql.conf:/etc/postgresql/postgresql.conf \
  -v $(pwd)/pg_hba.conf:/etc/postgresql/pg_hba.conf \
  postgis/postgis:13-3.5 \
  postgres -c 'config_file=/etc/postgresql/postgresql.conf'
```

### 资源限制

```bash
# 设置内存和CPU限制
docker run -d \
  --name postgis \
  -e POSTGRES_PASSWORD=mysecretpassword \
  --memory=2g \
  --cpus=2.0 \
  postgis/postgis:13-3.5
```

## 更新PostGIS扩展

容器包含一个更新脚本，可以用于更新PostGIS扩展到新版本：

```bash
# 更新PostGIS扩展
docker exec -it postgis update-postgis.sh
```

## 故障排除

### 多架构运行问题

如果在运行特定架构镜像时遇到"exec format error"错误，请检查以下几点：

1. 确保Docker已正确配置多架构支持：
   ```bash
   docker run --privileged --rm tonistiigi/binfmt --install all
   ```

2. 验证镜像是否包含目标架构：
   ```bash
   docker manifest inspect postgis/postgis:13-3.5
   ```

3. 使用正确的平台标志运行镜像：
   ```bash
   # 对于ARM64
   docker run --platform linux/arm64 -it --rm postgis/postgis:13-3.5
   
   # 对于AMD64
   docker run --platform linux/amd64 -it --rm postgis/postgis:13-3.5
   ```

### 连接问题

如果无法连接到数据库，请检查以下几点：

1. 确保容器正在运行：
   ```bash
   docker ps
   ```

2. 检查容器日志：
   ```bash
   docker logs postgis
   ```

3. 验证端口映射：
   ```bash
   docker port postgis
   ```

### 权限问题

如果遇到权限问题，请检查以下几点：

1. 确保数据目录权限正确：
   ```bash
   chmod 755 $(pwd)/data
   ```

2. 使用正确的用户运行容器：
   ```bash
   docker run -d \
     --name postgis \
     -e POSTGRES_PASSWORD=mysecretpassword \
     -u $(id -u):$(id -g) \
     postgis/postgis:13-3.5
   ```

## 许可证

本镜像遵循相关组件的许可证：
- PostgreSQL: PostgreSQL License
- PostGIS: GNU GPL v2
- Alpine Linux: MIT License

## 版本信息

- **PostgreSQL版本**: 13-17
- **PostGIS版本**: 3.5-3.6
- **基础镜像**: Alpine Linux
- **支持架构**: AMD64, ARM64