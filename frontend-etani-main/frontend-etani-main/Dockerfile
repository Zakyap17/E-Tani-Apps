# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.10.6 AS build-env

WORKDIR /app

# Copy the pubspec logic to get dependencies first (for better caching)
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the code and build
COPY . .
RUN flutter build web

# Stage 2: Serve using Nginx
FROM nginx:alpine

# Copy the build output from the first stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy our custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
