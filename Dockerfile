# Build stage - use full node image for building native modules
FROM node:24-trixie AS builder

# Install build dependencies for native modules (usb -> libusb)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    pkg-config \
    libusb-1.0-0-dev \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files first for better Docker layer caching
COPY package*.json ./

# Install production dependencies only - native modules are compiled here
RUN npm ci --omit=dev && npm cache clean --force

# Runtime stage - use slim image for smaller final image
FROM node:24-trixie-slim AS runtime

# Install only the runtime shared library for libusb
RUN apt-get update && apt-get install -y --no-install-recommends \
    libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 --ingroup nodejs nodejs

# Copy dependencies (with compiled native modules) and application code
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs index.js ./

USER nodejs

ENV NODE_ENV=production \
    PORT=9999

EXPOSE 9999

CMD ["node", "index.js"]
