# Open Lovable

Chat with AI to build React apps instantly. An example app made by the [Firecrawl](https://firecrawl.dev/?ref=open-lovable-github) team. For a complete cloud solution, check out [Lovable.dev ❤️](https://lovable.dev/).

<img src="https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbmZtaHFleGRsMTNlaWNydGdianI4NGQ4dHhyZjB0d2VkcjRyeXBucCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/ZFVLWMa6dVskQX0qu1/giphy.gif" alt="Open Lovable Demo" width="100%"/>



## Setup

1. **Clone & Install**
```bash
git clone https://github.com/mendableai/open-lovable.git
cd open-lovable
npm install
```

2. **Add `.env.local`**
```env
# Required
E2B_API_KEY=your_e2b_api_key  # Get from https://e2b.dev (Sandboxes)
FIRECRAWL_API_KEY=your_firecrawl_api_key  # Get from https://firecrawl.dev (Web scraping)

# Optional (need at least one AI provider)
ANTHROPIC_API_KEY=your_anthropic_api_key  # Get from https://console.anthropic.com
OPENAI_API_KEY=your_openai_api_key  # Get from https://platform.openai.com (GPT-5)
GEMINI_API_KEY=your_gemini_api_key  # Get from https://aistudio.google.com/app/apikey
GROQ_API_KEY=your_groq_api_key  # Get from https://console.groq.com (Fast inference - Kimi K2 recommended)
```

3. **Run**
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)  

## 🐳 Docker部署

### 快速开始

使用Docker快速运行Open Lovable：

```bash
# 使用Docker Compose（推荐）
docker-compose up -d

# 或者直接使用Docker
docker run -d \
  -p 3000:3000 \
  -e E2B_API_KEY=your_e2b_api_key \
  -e FIRECRAWL_API_KEY=your_firecrawl_api_key \
  -e ANTHROPIC_API_KEY=your_anthropic_api_key \
  --name open-lovable \
  ghcr.io/your-username/open-lovable:latest
```

### Docker Compose配置

1. **复制环境变量文件**
```bash
cp .env.example .env
```

2. **编辑环境变量**
```bash
# 编辑.env文件，填入实际的API密钥
nano .env
```

3. **启动服务**
```bash
# 构建并启动
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### docker-compose.yml详细说明

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL:-http://localhost:3000}
    image: open-lovable:latest
    container_name: open-lovable
    ports:
      - "3000:3000"  # 端口映射：主机端口:容器端口
    environment:
      # Next.js配置
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
      
      # 必需的API密钥
      - E2B_API_KEY=${E2B_API_KEY}                    # E2B代码执行沙箱
      - FIRECRAWL_API_KEY=${FIRECRAWL_API_KEY}        # Firecrawl网页抓取
      
      # AI服务提供商（至少需要一个）
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}        # Claude AI
      - OPENAI_API_KEY=${OPENAI_API_KEY}              # GPT模型
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}              # Gemini模型
      - GROQ_API_KEY=${GROQ_API_KEY}                  # Groq快速推理
      
      # 其他配置
      - NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL:-http://localhost:3000}
    volumes:
      # 持久化日志（可选）
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/api/health', (r) => {r.statusCode === 200 ? process.exit(0) : process.exit(1)})"]
      interval: 30s      # 每30秒检查一次
      timeout: 3s        # 3秒超时
      retries: 3         # 重试3次
      start_period: 40s  # 启动后40秒开始检查
    networks:
      - lovable-network

networks:
  lovable-network:
    driver: bridge
```

#### 配置选项说明

| 环境变量 | 说明 | 是否必需 | 获取地址 |
|---------|------|----------|----------|
| `E2B_API_KEY` | 代码执行沙箱服务 | 是 | [e2b.dev](https://e2b.dev) |
| `FIRECRAWL_API_KEY` | 网页抓取服务 | 是 | [firecrawl.dev](https://firecrawl.dev) |
| `ANTHROPIC_API_KEY` | Claude AI模型 | 否* | [console.anthropic.com](https://console.anthropic.com) |
| `OPENAI_API_KEY` | GPT模型 | 否* | [platform.openai.com](https://platform.openai.com) |
| `GOOGLE_API_KEY` | Gemini模型 | 否* | [aistudio.google.com](https://aistudio.google.com/app/apikey) |
| `GROQ_API_KEY` | Groq快速推理 | 否* | [console.groq.com](https://console.groq.com) |

*至少需要配置一个AI服务提供商

### Dockerfile构建详解

我们的Dockerfile使用多阶段构建优化镜像大小和安全性：

#### 第一阶段：依赖安装
```dockerfile
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN \
  if [ -f pnpm-lock.yaml ]; then \
    corepack enable pnpm && pnpm i --frozen-lockfile; \
  elif [ -f package-lock.json ]; then \
    npm ci; \
  else \
    npm install; \
  fi
```

#### 第二阶段：应用构建
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build
```

#### 第三阶段：生产运行
```dockerfile
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# 创建非root用户
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 复制构建结果
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
```

### 常用Docker命令

#### 构建镜像
```bash
# 基础构建
docker build -t open-lovable:latest .

# 指定平台构建
docker build --platform linux/amd64 -t open-lovable:latest .

# 不使用缓存重新构建
docker build --no-cache -t open-lovable:latest .
```

#### 运行容器
```bash
# 基础运行
docker run -p 3000:3000 open-lovable:latest

# 后台运行并设置环境变量
docker run -d \
  -p 3000:3000 \
  --env-file .env \
  --name open-lovable-app \
  open-lovable:latest

# 挂载本地目录用于开发
docker run -d \
  -p 3000:3000 \
  -v $(pwd):/app \
  -v /app/node_modules \
  --name open-lovable-dev \
  open-lovable:latest
```

#### 容器管理
```bash
# 查看运行状态
docker ps

# 查看日志
docker logs -f open-lovable-app

# 进入容器
docker exec -it open-lovable-app sh

# 停止容器
docker stop open-lovable-app

# 删除容器
docker rm open-lovable-app
```

### 生产环境部署

#### 使用反向代理（Nginx）
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### 资源限制
```bash
# 限制内存和CPU
docker run -d \
  -p 3000:3000 \
  -m 1g \
  --cpus="1.0" \
  --env-file .env \
  open-lovable:latest
```

#### 数据持久化
```bash
# 挂载日志目录
docker run -d \
  -p 3000:3000 \
  -v ./logs:/app/logs \
  -v ./data:/app/data \
  open-lovable:latest
```

### 故障排除

#### 常见问题

1. **端口占用**
```bash
# 检查端口占用
lsof -i :3000
# 更改端口
docker run -p 8080:3000 open-lovable:latest
```

2. **环境变量未生效**
```bash
# 检查容器环境变量
docker exec open-lovable-app env | grep API_KEY
```

3. **构建失败**
```bash
# 清理Docker缓存
docker builder prune
docker system prune -a
```

4. **容器启动失败**
```bash
# 查看详细日志
docker logs --details open-lovable-app
```

### 监控和维护

#### 健康检查
```bash
# 查看健康状态
docker inspect open-lovable-app | grep -A 10 Health
```

#### 资源监控
```bash
# 查看资源使用情况
docker stats open-lovable-app
```

#### 自动重启
```yaml
# 在docker-compose.yml中设置
restart: unless-stopped
```

## 🚀 CI/CD自动化

项目配置了GitHub Actions自动构建和推送Docker镜像：

### 配置GitHub Variables和Secrets

在GitHub仓库设置中配置以下变量：

#### Variables（仓库 → Settings → Secrets and variables → Actions → Variables）
- `DOCKER_USERNAME`: Docker Hub用户名

#### Secrets（仓库 → Settings → Secrets and variables → Actions → Secrets）
- `DOCKER_PASSWORD`: Docker Hub密码或访问令牌

### 自动构建触发条件

- 推送到 `main` 或 `master` 分支
- 创建版本标签（`v*`）
- 手动触发工作流

### 生成的镜像标签

每次构建会自动生成以下标签：
- `latest` - 最新版本
- `YYYYMMDD-HHMMSS` - 时间戳标签
- `YYYYMMDD` - 日期标签
- `{branch}-{sha}` - 分支和提交SHA

### 使用CI/CD构建的镜像

```bash
# 拉取最新版本
docker pull your-username/open-lovable:latest

# 拉取特定时间戳版本
docker pull your-username/open-lovable:20250815-143022

# 运行
docker run -d -p 3000:3000 --env-file .env your-username/open-lovable:latest
```

## License

MIT
