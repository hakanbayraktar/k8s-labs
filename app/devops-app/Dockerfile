FROM node:24-alpine
ARG APP_VERSION=1.0
ENV APP_VERSION=${APP_VERSION}
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY server.js .
USER node
EXPOSE 8080
CMD ["node", "server.js"]
