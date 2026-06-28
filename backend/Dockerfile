# 1. Base image
FROM node:20-alpine AS base
WORKDIR /app

# 2. Install dependencies
FROM base AS deps
COPY package*.json ./
RUN npm install

# 3. Build stage
FROM base AS build
COPY . .
COPY --from=deps /app/node_modules ./node_modules
RUN npx prisma generate
RUN npm run build

# 4. Runner (final image)
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN apk add --no-cache openssl

RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 expressjs

COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/package.json ./
COPY --from=build /app/src ./src

RUN chown -R expressjs:nodejs /app

USER expressjs

EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node src/server.js"]
