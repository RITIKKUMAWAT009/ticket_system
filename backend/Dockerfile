FROM node:20-alpine

WORKDIR /app

# Required by Prisma
RUN apk add --no-cache openssl

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Create non-root user
RUN addgroup -S nodejs && adduser -S expressjs -G nodejs

# Create uploads directory
RUN mkdir -p uploads

# Fix permissions
RUN chown -R expressjs:nodejs /app

USER expressjs

EXPOSE 3000

CMD ["node", "src/server.js"]
