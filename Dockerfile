FROM node:22.20.0 as build
WORKDIR /app/src
COPY main.lua conf.lua ./

RUN npm install -g love.js
RUN love.js /app/src /app/dist --title "ping-pong" --memory 16777216

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf
