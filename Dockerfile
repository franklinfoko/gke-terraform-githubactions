FROM node:lts-alpine AS builder 

WORKDIR /src
COPY package*.json ./
RUN npm install 
COPY . .
RUN npm run build 

FROM nginx:stable-alpine
COPY --from=builder /src/build /usr/share/nginx/html
EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
