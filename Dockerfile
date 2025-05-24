# Build stage - use full node image for building native modules
FROM node:22 AS builder

# Install build dependencies for native modules
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    libusb-dev \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy package files first for better Docker layer caching
COPY package*.json ./

# Install all dependencies (including dev dependencies for building)
RUN npm ci

# Copy application code
COPY index.js ./

# Runtime stage - use slim image for smaller final image
FROM node:22-slim AS runtime

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    libusb-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nodejs

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application code and built dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/index.js ./

# Change ownership to nodejs user
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 4001

CMD ["node", "index.js"]

