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

1. **复制环境变量**
```bash
cp .env.example .env
# 编辑.env文件，填入实际的API密钥
```

2. **使用Docker Compose启动**
```bash
docker-compose up -d
```

### Docker命令

#### 构建和运行
```bash
# 构建镜像
docker build -t open-lovable:latest .

# 运行容器
docker run -d -p 3000:3000 --env-file .env open-lovable:latest

# 查看日志
docker logs -f container_name
```

#### 管理容器
```bash
# 查看状态
docker ps

# 停止容器
docker stop container_name

# 删除容器
docker rm container_name
```

### Docker Compose配置

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - E2B_API_KEY=${E2B_API_KEY}
      - FIRECRAWL_API_KEY=${FIRECRAWL_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
      - GROQ_API_KEY=${GROQ_API_KEY}
    restart: unless-stopped
```

### 环境变量

| 变量名 | 必需 | 说明 |
|--------|------|------|
| `E2B_API_KEY` | 是 | 代码执行沙箱 |
| `FIRECRAWL_API_KEY` | 是 | 网页抓取服务 |
| `ANTHROPIC_API_KEY` | 否* | Claude AI |
| `OPENAI_API_KEY` | 否* | GPT模型 |
| `GOOGLE_API_KEY` | 否* | Gemini模型 |
| `GROQ_API_KEY` | 否* | Groq推理 |

*至少需要一个AI提供商

## License

MIT
