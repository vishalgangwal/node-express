# ─────────────────────────────────────────────
# Stage 1: Build / Install dependencies
# ─────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy only package files first (better layer caching)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# ─────────────────────────────────────────────
# Stage 2: Production image
# ─────────────────────────────────────────────
FROM node:20-alpine AS production

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy installed node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy app source code
COPY src/ ./src/
COPY package*.json ./

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

USER appuser

# Expose port
EXPOSE 3000

# Health check so Docker / Compose knows when the app is ready
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Set NODE_ENV
ENV NODE_ENV=production

CMD ["node", "src/server.js"]
