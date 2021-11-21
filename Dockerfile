FROM node:10-alpine as build

ENV PYTHONUNBUFFERED=1
RUN apk update && apk add --no-cache --virtual build-dependencies build-base gcc wget git python3
RUN ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

RUN chown -R node:node /srv

USER node
WORKDIR /srv


RUN git clone --depth=1 https://github.com/gchq/CyberChef.git .
RUN npm remove chromedriver --save-dev
RUN npx browserslist@latest --update-db
RUN npm install

ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN npx grunt prod


FROM docker.io/nginxinc/nginx-unprivileged:alpine as app
# old http-server was running on port 8000, avoid breaking change
RUN sed -i 's|listen       8080;|listen       8000;|g' /etc/nginx/conf.d/default.conf

COPY --from=build /srv/build/prod /usr/share/nginx/html

EXPOSE 8000