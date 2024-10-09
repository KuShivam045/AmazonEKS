FROM node:20-alpine
WORKDIR /app

# Copy only package.json and package-lock.json first
COPY package*.json ./

# Clean npm cache to prevent corruption issues
RUN npm cache clean --force

# Optionally, update npm to the latest version
RUN npm install -g npm@latest

# Run npm ci with verbose logging to troubleshoot further
RUN npm ci --verbose

# Copy the rest of your application
COPY . .

# Build your application
RUN npm run build

# Expose the port
EXPOSE 3000

# Install serve globally
RUN npm install -g serve

# Start the application
CMD ["serve", "-s", "build", "-l", "3000"]
