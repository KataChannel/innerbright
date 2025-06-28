FROM oven/bun:latest AS builder
# Set the working directory in the container
RUN apt-get update -y && apt-get install -y openssl libssl-dev
WORKDIR /app
COPY . .
RUN bun install --no-cache
COPY . .
# RUN bun install -g prisma
# RUN bun prisma migrate dev --name init1.1
# RUN bun prisma generate
FROM oven/bun:latest
RUN apt-get update -y && apt-get install -y openssl libssl-dev
WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /app/dist /app/dist
# COPY .env .env
EXPOSE 3333

# Run the application
CMD ["bun", "run", "dist/main.js"]
