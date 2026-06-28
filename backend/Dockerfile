FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm ci

COPY . .

RUN npx prisma generate

RUN addgroup -S nodejs && adduser -S expressjs -G nodejs
RUN mkdir -p uploads
RUN chown -R expressjs:nodejs /app

USER expressjs

EXPOSE 3000

CMD ["node", "src/server.js"]
