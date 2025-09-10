# 🚀 阿里云容器镜像服务配置指南

## 问题解决

### 1. Dockerfile包依赖问题修复

**问题**: Alpine Linux中包名错误导致构建失败
- ❌ `png-dev` (不存在的包)
- ❌ `jpeg-dev` (不推荐)
- ❌ `$CLASSPATH` 未定义变量

**解决方案**:
- ✅ `libpng-dev` (PNG开发库)
- ✅ `libjpeg-turbo-dev` (JPEG开发库)
- ✅ `CLASSPATH=/usr/share/java/gdal.jar` (直接设置)

### 2. 环境变量修复

```dockerfile
# 修复前
ENV CLASSPATH=$CLASSPATH:/usr/share/java/gdal.jar  # ❌ 未定义变量

# 修复后  
ENV CLASSPATH=/usr/share/java/gdal.jar              # ✅ 直接设置
```

## 阿里云容器镜像服务集成

### 配置概述

现在工作流支持同时推送到两个镜像仓库：
- **GitHub Container Registry**: `ghcr.io/nickilchen/dockerfile/gdal-multi-arch`  
- **阿里云容器镜像服务**: `registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1`

### 镜像标签策略

| 分支/事件 | GitHub镜像标签 | 阿里云镜像标签 |
|----------|---------------|---------------|
| `main`分支 | `latest`, `stable` | `3.7.1`, `latest` |
| `develop`分支 | `dev`, `nightly` | `3.7.1-dev` |
| 版本标签`v1.0.0` | `1.0.0`, `latest` | `3.7.1`, `latest` |

### 环境变量配置

在工作流中添加了以下配置：

```yaml
env:
  REGISTRY: ghcr.io
  ALI_REGISTRY: registry.cn-hangzhou.aliyuncs.com
  IMAGE_NAME: ${{ github.repository }}/gdal-multi-arch
  ALI_IMAGE_NAME: nickilchen/gdal
  GDAL_VERSION: "3.7.1"
```

## GitHub Secrets 配置

需要在GitHub仓库中设置以下Secrets：

### 1. 阿里云容器镜像服务凭据

1. **进入阿里云控制台**
   - 访问：https://cr.console.aliyun.com/
   - 选择所在地域：华东1（杭州）

2. **创建个人实例（如果没有）**
   - 点击"个人实例" → "创建个人实例"
   - 设置Registry登录密码

3. **获取凭据信息**
   - 用户名：阿里云账号全名（如：nickilchen@example.com）
   - 密码：Registry登录密码
   - 仓库地址：`registry.cn-hangzhou.aliyuncs.com`

### 2. 在GitHub中设置Secrets

在GitHub仓库中设置以下Secrets：

```
Settings → Secrets and variables → Actions → New repository secret
```

添加以下Secrets：

| Secret名称 | 值 | 说明 |
|-----------|----|----|
| `ALI_REGISTRY_USERNAME` | 您的阿里云账号全名 | 阿里云容器镜像服务用户名 |
| `ALI_REGISTRY_PASSWORD` | Registry登录密码 | 阿里云容器镜像服务密码 |

### 3. 验证配置

```bash
# 测试阿里云登录
docker login registry.cn-hangzhou.aliyuncs.com
```

## 使用方法

### 自动构建和推送

1. **推送代码到main分支**：
   ```bash
   git push origin main
   ```
   
   将构建并推送：
   - `ghcr.io/nickilchen/dockerfile/gdal-multi-arch:latest`
   - `registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1`

2. **创建版本标签**：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   
   将构建并推送：
   - `ghcr.io/nickilchen/dockerfile/gdal-multi-arch:1.0.0`
   - `registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1`

### 手动触发构建

```bash
# 使用GitHub CLI
gh workflow run docker-build.yml

# 或在GitHub网页界面中点击"Run workflow"
```

### 拉取镜像

```bash
# 从GitHub Container Registry拉取
docker pull ghcr.io/nickilchen/dockerfile/gdal-multi-arch:latest

# 从阿里云容器镜像服务拉取  
docker pull registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1

# 指定架构拉取
docker pull --platform linux/amd64 registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1
docker pull --platform linux/arm64 registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1
```

## 构建监控

### 构建状态查看

工作流运行后会显示：

```
🔧 Build Configuration:
  📦 Registry: ghcr.io
  🏷️ Image: nickilchen/dockerfile/gdal-multi-arch
  🏗️ Platforms: linux/amd64,linux/arm64
  📤 Push: true
  🔖 GitHub Tags: ghcr.io/nickilchen/dockerfile/gdal-multi-arch:latest,ghcr.io/nickilchen/dockerfile/gdal-multi-arch:stable
  🔖 Aliyun Tags: registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1,registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:latest
  🗂️ Cache Key: gdal-3.7.1-java8-linux-amd64-linux-arm64
```

### 验证推送结果

1. **GitHub Container Registry**:
   - 访问：https://github.com/nickilchen/dockerfile/pkgs/container/gdal-multi-arch

2. **阿里云容器镜像服务**:
   - 访问：https://cr.console.aliyun.com/repository/
   - 查看 `nickilchen/gdal` 仓库

## 故障排除

### 常见错误

1. **阿里云登录失败**
   ```
   Error: buildx failed with: ERROR: failed to solve: failed to push
   ```
   
   **解决方案**：
   - 检查ALI_REGISTRY_USERNAME和ALI_REGISTRY_PASSWORD是否正确设置
   - 确认阿里云账号是否开通容器镜像服务
   - 验证Registry登录密码是否正确

2. **命名空间不存在**
   ```
   Error: repository does not exist
   ```
   
   **解决方案**：
   - 在阿里云控制台创建命名空间 `nickilchen`
   - 创建仓库 `gdal`

3. **权限不足**
   ```
   Error: insufficient_scope: authorization failed
   ```
   
   **解决方案**：
   - 确认账号拥有推送权限
   - 检查仓库访问级别设置

### 调试命令

```bash
# 本地测试阿里云推送
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --push \
  --tag registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1 \
  ./gdal

# 查看镜像信息
docker manifest inspect registry.cn-hangzhou.aliyuncs.com/nickilchen/gdal:3.7.1
```

## 最佳实践

1. **定期更新凭据**: 建议定期更换Registry登录密码
2. **监控构建状态**: 关注GitHub Actions工作流执行状态
3. **镜像安全扫描**: 利用内置的Trivy安全扫描功能
4. **合理使用缓存**: 工作流已配置智能缓存以加快构建速度

---

配置完成后，您的GDAL多架构镜像将自动构建并同时推送到GitHub和阿里云两个镜像仓库！🚀