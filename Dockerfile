FROM node:20-alpine AS builder
WORKDIR /app
COPY services/fundraising-service/package.json services/fundraising-service/package-lock.json ./
RUN npm ci
COPY services/fundraising-service ./
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/dist/client ./dist/client
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
COPY --from=builder /app/scripts ./scripts
RUN npm ci --omit=dev
CMD ["node","dist/src/main.js"]
