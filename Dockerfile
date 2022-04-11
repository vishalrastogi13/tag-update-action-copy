FROM node:14.18.2

MAINTAINER sumitkumar@sharechat.co

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && apt-get install -y \
    curl \
    jq \

RUN npm install -g npm-check-updates \
    npm install \
    npm install -g semver \

ENTRYPOINT ["/entrypoint.sh"]