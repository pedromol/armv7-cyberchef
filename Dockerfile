FROM docker.io/node:10 as build

RUN chown -R node:node /srv

USER node
WORKDIR /srv

RUN git clone --depth=1 https://github.com/gchq/CyberChef.git .
RUN npx browserslist@latest --update-db
RUN npm remove chromedriver --save-dev
RUN npm install

ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN npx grunt prod


FROM docker.io/nginxinc/nginx-unprivileged:alpine as app
# old http-server was running on port 8000, avoid breaking change
RUN sed -i 's|listen       8080;|listen       8000;|g' /etc/nginx/conf.d/default.conf

COPY --from=build /srv/build/prod /usr/share/nginx/html

EXPOSE 8000