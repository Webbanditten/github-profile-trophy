# Use official Deno image (alpine variant for smaller size)
FROM denoland/deno:alpine

# Set working directory
WORKDIR /app

# Copy all application files
COPY . .

# Cache the dependencies and main application
RUN deno cache main.ts

# Expose the port
EXPOSE 8080

# Set the user to non-root for security
USER deno

# Run the application
CMD ["deno", "run", "-A", "main.ts"]
