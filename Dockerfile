FROM node:alpine

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /app

COPY . .

RUN printf '#!/bin/sh\nif [ ! -f "package-lock.json" ] || [ ! -d "node_modules" ]; then\n    npm install\nfi\n' > /usr/local/bin/npm_install \
    && chmod +x /usr/local/bin/npm_install
RUN adduser -D -s /bin/sh appuser

EXPOSE 4200
USER appuser

CMD npm_install && npm run start
