# Docker 镜像构建 (Kaniko)

## 概述

**Kaniko** 是 Google 开发的工具，可以在无需 Docker daemon 的情况下构建 Docker 镜像。

## 核心优势

| 特性 | Docker Buildx | Kaniko |
|------|---------------|--------|
| 需要 Docker daemon | ✅ | ❌ |
| 支持 BuildKit | ✅ | ✅ |
| 缓存层 | ✅ | ✅ |
| 多平台构建 | ✅ | ✅ |
| 远程集群构建 | ❌ | ✅ |
| **本地无 daemon** | ❌ | ✅ |

## 适用场景

- 本地 Docker 不可用或损坏
- CI/CD 环境没有 Docker-in-Docker
- 在 Kubernetes 集群中构建镜像
- 需要构建镜像但没有 root 权限

## 安装

### 方式一：二进制

```bash
# 下载 Kaniko
curl -Lo kaniko https://github.com/GoogleContainerTools/kaniko/releases/download/v1.23.0/kaniko-v1.23.0-linux-amd64
chmod +x kaniko
sudo mv kaniko /usr/local/bin/
```

### 方式二：Docker

```bash
# 使用 Kaniko 镜像
docker run --rm -v $(pwd):/workspace gcr.io/kaniko-project/executor:latest \
  --context=/workspace \
  --destination=my-image:tag
```

## 本地使用

### 基础构建

```bash
# 最简构建
kaniko \
  --context ./ \
  --dockerfile Dockerfile \
  --destination my-image:latest
```

### 推送到镜像仓库

```bash
kaniko \
  --context ./ \
  --dockerfile Dockerfile \
  --destination docker.io/username/my-image:latest \
  --destination registry.example.com/my-image:v1.0
```

### 完整示例

```bash
#!/bin/bash
# 构建并推送镜像

# 配置
IMAGE_NAME="my-app"
IMAGE_TAG="latest"
REGISTRY="docker.io"
USERNAME="myuser"

# 构建上下文
CONTEXT_DIR="./"
DOCKERFILE_PATH="./Dockerfile"

# 完整镜像地址
DESTINATION="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "开始构建镜像: ${DESTINATION}"

# 执行构建
kaniko \
  --context "${CONTEXT_DIR}" \
  --dockerfile "${DOCKERFILE_PATH}" \
  --destination "${DESTINATION}" \
  --snapshotMode redo \
  --single-snapshot \
  --cache=true \
  --cache-dir=/tmp/kaniko-cache

echo "构建完成: ${DESTINATION}"
```

## 镜像源配置

### 使用国内镜像加速

```bash
# 设置镜像源映射
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --registry-mirror https://mirror.ccs.tencentyun.com \
  --registry-mirror https://registry.docker-cn.com \
  --registry-mirror https://docker.m.daocloud.io
```

### 常用镜像源

| 镜像源 | 地址 |
|--------|------|
| 腾讯云 | `https://mirror.ccs.tencentyun.com` |
| 阿里云 | `https://registry.cn-hangzhou.aliyuncs.com` |
| DaoCloud | `https://docker.m.daocloud.io` |
| 1Panel | `https://docker.1panel.live` |

### 配置文件方式

创建 `~/.kaniko/config.json`:

```json
{
  "mirrors": [
    "mirror.ccs.tencentyun.com",
    "registry.cn-hangzhou.aliyuncs.com"
  ]
}
```

## 认证配置

### 私有镜像仓库

```bash
# 使用密钥文件
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination registry.example.com/my-image:tag \
  --secret-file ./kaniko-secret.json
```

### Docker 配置

```bash
# 使用 Docker config
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --docker-config ~/.docker
```

## 缓存

### 启用构建缓存

```bash
# 启用缓存
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --cache=true \
  --cache-dir=/tmp/kaniko-cache
```

### 远程缓存

```bash
# 使用 GCR 作为缓存
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --cache=true \
  --cache-repo gcr.io/my-project/cache \
  --cache=true
```

## Kubernetes 中使用

### 创建 Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kaniko-builder
spec:
  containers:
  - name: builder
    image: gcr.io/kaniko-project/executor:latest
    args:
    - --context=/workspace
    - --dockerfile=/workspace/Dockerfile
    - --destination=my-registry.com/my-image:tag
    volumeMounts:
    - name: workspace
      mountPath: /workspace
  volumes:
  - name: workspace
    emptyDir: {}
  restartPolicy: Never
```

### 创建 Job (推荐)

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: kaniko-build
spec:
  ttlSecondsAfterFinished: 300
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:latest
        args:
        - --context=git
        - --dockerfile=Dockerfile
        - --destination=my-registry.com/my-image:tag
        - --git=branch=main
        - --context-sub-path=.
        env:
        - name: GIT_TOKEN
          valueFrom:
            secretKeyRef:
              name: git-secret
              key: token
      serviceAccountName: kaniko
```

### RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kaniko
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kaniko
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "create", "delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kaniko
subjects:
- kind: ServiceAccount
  name: kaniko
roleRef:
  kind: Role
  name: kaniko
  apiGroup: rbac.authorization.k8s.io
```

## 高级用法

### 多阶段构建

```bash
# 支持多阶段构建
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --target production \
  --destination my-image:tag
```

### 自定义构建参数

```bash
# 传递构建参数
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --build-arg VERSION=1.0.0 \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

### 跳过 TLS 验证

```bash
# 用于自签名证书的私有仓库
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --insecure \
  --skip-tls-verify
```

## 故障排查

### 构建失败

```bash
# 查看详细日志
kaniko \
  --context . \
  --dockerfile Dockerfile \
  --destination my-image:tag \
  --verbosity debug
```

### 权限问题

```bash
# 检查镜像仓库权限
echo "username" | base64
echo "password" | base64

# 创建密钥
kubectl create secret docker-registry my-registry-secret \
  --docker-server=registry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword
```

### 磁盘空间不足

```bash
# 清理缓存
rm -rf /tmp/kaniko-cache

# 使用更小的缓存目录
kaniko --cache-dir=/another/path ...
```

### 镜像源问题

```bash
# 测试镜像源连通性
curl -I https://mirror.ccs.tencentyun.com
curl -I https://registry.cn-hangzhou.aliyuncs.com
```

## 命令行参数速查

| 参数 | 简写 | 说明 |
|------|------|------|
| `--context` | `-c` | 构建上下文目录 |
| `--dockerfile` | `-d` | Dockerfile 路径 |
| `--destination` | `-d` | 目标镜像地址 |
| `--registry-mirror` | - | 镜像源地址 |
| `--cache` | - | 启用缓存 |
| `--cache-dir` | - | 缓存目录 |
| `--build-arg` | - | 构建参数 |
| `--target` | - | 多阶段构建目标 |
| `--insecure` | - | 允许非安全仓库 |
| `--skip-tls-verify` | - | 跳过 TLS 验证 |
| `--verbosity` | - | 日志级别 |

## 参考

- [Kaniko 官方文档](https://github.com/GoogleContainerTools/kaniko)
- [Kaniko GitHub](https://github.com/GoogleContainerTools/kaniko)
- [Kaniko 镜像源配置](https://github.com/GoogleContainerTools/kaniko#configuring-registry-mirrors)
