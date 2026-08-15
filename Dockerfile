# Use a lightweight Node base image
FROM node:20-alpine AS builder

# Install system dependencies needed to compile the Rust/Wasm modules
RUN apk add --no-cache rust cargo git binaryen

# Install pnpm globally
RUN npm install -g pnpm

# Set the working directory inside the container
WORKDIR /app

# Copy all repository files into the container
COPY . .

# Install project dependencies
RUN pnpm install --frozen-lockfile

# Build the WebAssembly rewriter engine first, then build the core package
RUN cd packages/core && pnpm rewriter:build && pnpm build

# --- Production Environment ---
FROM node:20-alpine
RUN npm install -g pnpm
WORKDIR /app

# Copy only the compiled build files from the builder stage to keep the image small
COPY --from=builder /app /app

# Expose Scramjet's default network port
EXPOSE 4141

# Start the dev server
CMD ["pnpm", "dev"]
