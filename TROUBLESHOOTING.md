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

修复日期：2025-09-10
修复版本：所有工作流文件 v1.0.1