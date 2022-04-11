FROM node:14.18.2

MAINTAINER sumitkumar@sharechat.co

COPY entrypoint.sh /entrypoint.sh
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    npm install \
    npm install semver

ENTRYPOINT ["/entrypoint.sh"]
