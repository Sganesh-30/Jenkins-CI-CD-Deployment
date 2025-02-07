# First stage: Build
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Final image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app /app/
CMD ["node", "index.js"]
