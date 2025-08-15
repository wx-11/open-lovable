# 多阶段构建 - Next.js应用
# 第一阶段：依赖安装
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# 复制依赖文件
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# 根据锁文件选择合适的包管理器安装
RUN \
  if [ -f pnpm-lock.yaml ]; then \
    corepack enable pnpm && pnpm i --frozen-lockfile; \
  elif [ -f package-lock.json ]; then \
    npm ci; \
  else \
    echo "Warning: No lockfile found, using npm install" && \
    npm install; \
  fi

# 第二阶段：构建应用
FROM node:20-alpine AS builder
WORKDIR /app

# 复制依赖
COPY --from=deps /app/node_modules ./node_modules

# 复制源代码
COPY . .

# 设置环境变量（可选）
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# 如果有环境文件模板，创建实际的环境文件
RUN if [ -f .env.example ]; then cp .env.example .env.local; fi

# 构建Next.js应用
RUN npm run build

# 第三阶段：生产运行
FROM node:20-alpine AS runner
WORKDIR /app

# 添加非root用户
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# 设置环境为生产
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# 复制必要的文件
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# 自动识别standalone模式
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# 如果不是standalone模式，复制完整的.next目录和node_modules
# COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
# COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules

# 切换到非root用户
USER nextjs

# 暴露端口
EXPOSE 3000

# 设置端口环境变量
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {r.statusCode === 200 ? process.exit(0) : process.exit(1)})" || exit 1

# 启动应用
CMD ["node", "server.js"]