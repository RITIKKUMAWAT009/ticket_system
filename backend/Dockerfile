FROM node:20-alpine AS base
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

FROM base AS build
COPY package.json package-lock.json* ./
RUN npm ci
COPY prisma ./prisma
RUN npx prisma generate
COPY . .

FROM base AS runner
ENV NODE_ENV=production

# Fix the libssl warning and Prisma engine dependency
RUN apk add --no-cache openssl

RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 expressjs

COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/prisma ./prisma
COPY package.json ./
COPY src ./src

# Allow the non-root user to write Prisma engine files
RUN chown -R expressjs:nodejs /app/node_modules/.prisma

RUN mkdir -p uploads && chown expressjs:nodejs uploads

USER expressjs
EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node src/server.js"]
