FROM node:14.18.2

MAINTAINER sumitkumar@sharechat.co

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update \
    && apt-get install -y curl
    
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
