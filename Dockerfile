# Build stage
FROM node:22-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG BUILD_MODE=production
RUN npm run build -- --mode ${BUILD_MODE}

# Production stage
FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

RUN VITE_GRAPHQL_URI=__VITE_GRAPHQL_URI_PLACEHOLDER__ \
    VITE_SERVER_URI=__VITE_SERVER_URI_PLACEHOLDER__ \
    npm run build -- --mode production

    COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]