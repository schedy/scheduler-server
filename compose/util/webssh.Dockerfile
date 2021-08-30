FROM node:14.17-alpine
WORKDIR /usr/src
COPY lib/webssh/ /usr/src/
RUN npm install --production
EXPOSE 2222/tcp
