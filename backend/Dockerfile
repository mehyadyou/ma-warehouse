# ─── مرحلهٔ ساخت ───
FROM node:22-alpine AS build
WORKDIR /app

# کش لایه‌ها: اول manifest ها، بعد سورس
COPY package.json package-lock.json ./
# اسکریپت‌های postinstall پرisma برای تولید کلاینت لازم است
RUN npm config set ignore-scripts false && npm ci

COPY prisma ./prisma
RUN npx prisma generate

COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ─── مرحلهٔ اجرا — فقط وابستگی‌های production ───
FROM node:22-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production

# کاربر غیر root
RUN addgroup -S app && adduser -S app -G app

COPY package.json package-lock.json ./
RUN npm config set ignore-scripts false && npm ci --omit=dev && npm config set ignore-scripts true && npm cache clean --force

# کلاینت پرisma تولیدشده + خروجی build
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/node_modules/@prisma ./node_modules/@prisma
COPY --from=build /app/node_modules/prisma ./node_modules/prisma
COPY --from=build /app/dist ./dist
COPY --from=build /app/src/config ./src/config

# پوشهٔ آپلودها (در استقرار واقعی volume بدهید)
RUN mkdir -p /app/uploads && chown -R app:app /app
VOLUME ["/app/uploads"]

USER app

EXPOSE 3000

# به‌جای CMD، همان server.ts کامپایل‌شده اجرا می‌شود
CMD ["node", "dist/server.js"]
