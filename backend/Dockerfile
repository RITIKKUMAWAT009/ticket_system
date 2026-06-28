FROM base AS runner
ENV NODE_ENV=production

# Install OpenSSL to silence the libssl warning
RUN apk add --no-cache openssl

RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 expressjs

COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/prisma ./prisma
COPY package.json ./
COPY src ./src

# Give the non-root user write access to ALL Prisma directories (engines live here)
RUN chown -R expressjs:nodejs /app/node_modules/.prisma /app/node_modules/@prisma

RUN mkdir -p uploads && chown expressjs:nodejs uploads

USER expressjs
EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && node src/server.js"]
