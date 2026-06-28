FROM node:20-alpine AS base
WORKDIR /app

# Install system deps for Prisma + OpenSSL
RUN apk add --no-cache openssl

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy full project
COPY . .

# Prisma generate
RUN npx prisma generate

# Optional: run as non-root user
RUN addgroup --system nodejs && adduser --system expressjs
RUN chown -R expressjs:nodejs /app

USER expressjs

EXPOSE 3000

# Run migrations + server
CMD ["sh", "-c", "npx prisma migrate deploy && node src/server.js"]
