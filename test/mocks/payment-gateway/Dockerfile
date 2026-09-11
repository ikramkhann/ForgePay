# AI Attribution Block: Minimal unprivileged Dockerfile for mock payment gateway
FROM node:20-alpine
WORKDIR /app
COPY package.json server.js ./
USER node
EXPOSE 8088
CMD ["node", "server.js"]
