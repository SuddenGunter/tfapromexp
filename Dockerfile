FROM node:22
RUN apt-get update && apt-get install -y \
    libusb-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY package.json /app
COPY package-lock.json /app
RUN npm install
COPY index.js /app
CMD node index.js

