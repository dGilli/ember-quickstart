FROM node:alpine

WORKDIR /app

COPY . .

RUN echo '#!/bin/sh\nif [ ! -f "package-lock.json" ] || [ ! -d "node_modules" ]; then npm install; fi' > /usr/local/bin/npm_install \
    && chmod +x /usr/local/bin/npm_install
RUN adduser -D -s /bin/sh appuser

EXPOSE 4200
USER appuser

CMD npm_install && npm run start
