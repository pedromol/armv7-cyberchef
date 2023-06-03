FROM node:18-alpine as build

RUN apk add git
WORKDIR /srv

RUN git clone https://github.com/gchq/CyberChef.git .
RUN npm install
RUN npx grunt prod


FROM docker.io/nginxinc/nginx-unprivileged:alpine as app
RUN sed -i 's|listen       8080;|listen       8000;|g' /etc/nginx/conf.d/default.conf

COPY --from=build /srv/build/prod /usr/share/nginx/html

EXPOSE 8000