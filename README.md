# MyApp — Node.js + Docker + Jenkins CI/CD

A production-ready Node.js/Express project with Docker multi-stage builds and a full Jenkins declarative pipeline.

---

## Project Structure

```
myapp/
├── src/
│   ├── app.js          # Express app (routes)
│   └── server.js       # Server entry point
├── test/
│   └── app.test.js     # Jest + Supertest tests
├── Dockerfile          # Multi-stage Docker build
├── docker-compose.yml  # Production compose
├── docker-compose.dev.yml  # Dev overrides (hot reload)
├── Jenkinsfile         # Declarative CI/CD pipeline
├── .env.example        # Environment variable template
├── .dockerignore
├── .gitignore
└── package.json
```

---

## Local Development

```bash
# 1. Install dependencies
npm install

# 2. Run tests
npm test

# 3. Start development server (with nodemon)
npm run dev
```

---

## Docker

```bash
# Build the image
docker build -t myapp:latest .

# Run the container
docker run -p 3000:3000 myapp:latest

# Using docker-compose (production)
docker-compose up -d

# Using docker-compose (development with hot-reload)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

---

## Jenkins Setup

### Prerequisites
- Jenkins with Docker installed on the agent
- The following plugins: Pipeline, Docker Pipeline, HTML Publisher

### Steps

1. **Create a new Pipeline job** in Jenkins
2. Set **Pipeline Definition** → `Pipeline script from SCM`
3. Set SCM to **Git** and paste your GitHub repo URL
4. Set **Script Path** to `Jenkinsfile`
5. Add a **credential** in Jenkins with ID `dockerhub-credentials` (username + password for Docker Hub)
6. In `Jenkinsfile`, update `DOCKER_REGISTRY` to your Docker Hub username

### Pipeline Stages

| Stage | Description |
|---|---|
| Checkout | Pulls the latest code from GitHub |
| Install Dependencies | Runs `npm ci` inside a Node.js Docker container |
| Run Tests | Runs Jest tests and publishes coverage report |
| Build Docker Image | Builds and tags the image with the Git commit SHA |
| Push to Registry | Pushes to Docker Hub (main/master branch only) |
| Deploy | Runs `docker-compose up -d` on the server |

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/` | Welcome message |
| GET | `/health` | Health check (used by Docker + load balancers) |
| GET | `/api/users` | Sample users list |

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `NODE_ENV` | `development` | Environment name |
| `PORT` | `3000` | Server port |
| `APP_VERSION` | `1.0.0` | App version tag |

Copy `.env.example` to `.env` and edit as needed. Never commit `.env` to Git.
