# 🚀 CI/CD 配置指南

本项目使用GitHub Actions实现多架构Docker镜像的自动化构建、测试和部署。

## 📋 工作流概述

### 🐳 主要工作流

| 工作流文件 | 触发条件 | 功能 |
|-----------|----------|------|
| [`docker-build.yml`](.github/workflows/docker-build.yml) | Push、PR、Tag、手动触发 | 多架构Docker镜像构建和推送 |
| [`release.yml`](.github/workflows/release.yml) | 发布、手动版本管理 | 版本管理和发布流程 |
| [`cache-management.yml`](.github/workflows/cache-management.yml) | 定时、手动触发 | 构建缓存管理和性能优化 |
| [`deployment.yml`](.github/workflows/deployment.yml) | 自动部署、手动触发 | 多环境部署流程 |

## 🏗️ 构建流程

### 自动构建触发条件

```yaml
# 推送到主分支
push:
  branches: [main, develop]
  paths: ['gdal/**']

# Pull Request
pull_request:
  branches: [main, develop]
  paths: ['gdal/**']

# 标签推送
push:
  tags: ['v*.*.*', 'gdal-*']
```

### 支持的架构

- `linux/amd64` (x86_64)
- `linux/arm64` (aarch64)

### 镜像标签策略

| 分支/标签 | 生成的标签 | 说明 |
|----------|------------|------|
| `main` | `latest`, `stable` | 主分支稳定版 |
| `develop` | `dev`, `nightly` | 开发分支 |
| `v1.2.3` | `1.2.3`, `latest` | 版本标签 |
| PR | `pr-123` | Pull Request |

## 🔧 手动构建

### 基本构建

```bash
# 在GitHub Actions页面手动触发，或者：
gh workflow run docker-build.yml
```

### 自定义构建参数

```bash
# 指定平台和标签
gh workflow run docker-build.yml \
  -f platforms="linux/amd64" \
  -f tag_suffix="-test" \
  -f push_to_registry=false
```

## 📦 版本管理

### 自动版本发布

1. **创建标签**：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **自动触发**：
   - 构建多架构镜像
   - 创建GitHub Release
   - 推送到镜像仓库

### 手动版本管理

```bash
# 创建新版本（补丁版本）
gh workflow run release.yml -f version_type=patch

# 创建预发布版本
gh workflow run release.yml -f version_type=prerelease -f prerelease=true
```

## 🚀 部署流程

### 环境配置

| 环境 | 分支 | URL | 说明 |
|------|------|-----|------|
| Development | `develop` | https://dev-gdal.example.com | 开发环境 |
| Staging | `main` | https://staging-gdal.example.com | 预发布环境 |
| Production | 发布标签 | https://gdal.example.com | 生产环境 |

### 自动部署

- **开发环境**：`develop`分支推送时自动部署
- **预发布环境**：`main`分支推送时自动部署
- **生产环境**：发布新版本时自动部署

### 手动部署

```bash
# 部署到指定环境
gh workflow run deployment.yml \
  -f environment=staging \
  -f image_tag=v1.0.0

# 强制部署到生产环境
gh workflow run deployment.yml \
  -f environment=production \
  -f image_tag=latest \
  -f force_deploy=true
```

## 📊 缓存管理

### 自动缓存优化

- **缓存预热**：每周日自动预热构建缓存
- **智能缓存**：基于平台和GDAL版本的分层缓存

### 手动缓存操作

```bash
# 预热缓存
gh workflow run cache-management.yml -f action=warm-cache

# 清理缓存
gh workflow run cache-management.yml -f action=clear-cache

# 分析缓存性能
gh workflow run cache-management.yml -f action=analyze-cache

# 性能基准测试
gh workflow run cache-management.yml -f action=benchmark-build
```

## 🔐 安全配置

### 必需的Secrets

| Secret | 用途 | 设置方法 |
|--------|------|----------|
| `GITHUB_TOKEN` | GitHub API访问 | 自动提供 |
| 其他密钥 | 根据部署需求 | Repository Settings → Secrets |

### 镜像安全

- **自动漏洞扫描**：每次构建时使用Trivy扫描
- **签名验证**：生产部署前验证镜像签名
- **最小权限**：使用非root用户运行

## 📈 监控和报告

### 构建监控

- **构建状态**：实时构建状态报告
- **构建时间**：性能基准测试
- **缓存命中率**：缓存效率分析

### 部署监控

- **健康检查**：部署后自动健康检查
- **回滚机制**：失败时自动回滚
- **告警通知**：异常情况及时通知

## 🛠️ 开发指南

### 本地测试构建

```bash
# 使用本地构建脚本
cd gdal
./build.sh --platforms linux/amd64 --no-push

# 使用docker-compose测试
docker-compose up -d
```

### 工作流调试

1. **查看日志**：
   ```bash
   gh run list --workflow=docker-build.yml
   gh run view <run-id> --log
   ```

2. **下载构建产物**：
   ```bash
   gh run download <run-id>
   ```

### 自定义工作流

如需自定义工作流，可以：

1. 复制现有工作流文件
2. 修改触发条件和参数
3. 调整构建步骤
4. 测试验证

## 🚨 故障排除

### 常见问题

1. **构建失败**：
   - 检查Dockerfile语法
   - 验证依赖可用性
   - 查看构建日志

2. **缓存问题**：
   - 清理过期缓存
   - 检查缓存键配置
   - 重新预热缓存

3. **部署失败**：
   - 验证镜像存在
   - 检查环境配置
   - 查看部署日志

### 获取帮助

- 查看GitHub Actions日志
- 检查工作流文件配置
- 联系维护团队

## 📚 最佳实践

### 构建优化

1. **合理使用缓存**：充分利用GitHub Actions缓存
2. **分层构建**：优化Dockerfile减少重复构建
3. **并行构建**：多架构并行构建提高效率

### 版本管理

1. **语义化版本**：遵循SemVer版本规范
2. **清晰的发布说明**：详细描述变更内容
3. **测试充分**：发布前充分测试

### 部署策略

1. **渐进式部署**：从开发到生产逐步部署
2. **健康检查**：部署后验证应用状态
3. **快速回滚**：准备好回滚方案

## 🔄 更新和维护

### 定期维护任务

- **依赖更新**：定期更新基础镜像和依赖
- **安全扫描**：定期执行安全漏洞扫描
- **性能优化**：监控和优化构建性能
- **文档更新**：保持文档同步更新

### 监控指标

- 构建成功率 > 95%
- 平均构建时间 < 15分钟（AMD64）< 20分钟（ARM64）
- 缓存命中率 > 80%
- 部署成功率 > 98%

---

## 📞 支持

如果您在使用CI/CD流程中遇到问题，请：

1. 查看工作流运行日志
2. 查阅本文档和相关README
3. 在GitHub Issues中报告问题
4. 联系项目维护团队