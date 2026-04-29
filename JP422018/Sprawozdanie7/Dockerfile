# ETAP 1: Instalacja zależności
FROM node:20-alpine AS deps
RUN corepack enable && corepack prepare pnpm@10.29.2 --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# ETAP 2: Budowanie
# Wymagane: next.config.js musi zawierać output: 'standalone'
FROM node:20-alpine AS builder
RUN corepack enable && corepack prepare pnpm@10.29.2 --activate
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN pnpm build

# ETAP 3: Produkcja
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

ARG GIT_COMMIT=unknown
ARG BUILD_NUMBER=unknown
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      ci.build.number="${BUILD_NUMBER}"

RUN addgroup -S nodejs && adduser -S -u 1001 nextjs
USER nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

EXPOSE 3000

CMD ["node", "server.js"]