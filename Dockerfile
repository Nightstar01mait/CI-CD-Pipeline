# Base image (replace this with the actual required environment, e.g., node:18-alpine, python:3.10-slim)
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy dependency files first to leverage Docker cache
# Example for Node.js:
# COPY package.json package-lock.json ./
# RUN npm ci

# Example for Python:
# COPY requirements.txt ./
# RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application source code
COPY . .

# Build step (if applicable, e.g., for frontend apps or compiled languages)
# RUN npm run build

# Stage 2: Production environment
FROM node:18-alpine AS runner

# Set production environment variable
ENV NODE_ENV=production

WORKDIR /app

# Copy built assets or required runtime files from the previous stage
# Example for Node.js:
# COPY --from=builder /app/package.json ./
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/dist ./dist

# Example: Expose the port the app runs on
EXPOSE 8080

# Command to run the application
# Example for Node.js:
# CMD ["node", "dist/index.js"]
# Example for Python:
# CMD ["python", "app.py"]
CMD ["echo", "Replace this CMD with the actual starting command"]
