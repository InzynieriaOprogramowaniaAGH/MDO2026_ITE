FROM node:20 AS build

WORKDIR /app

RUN apt update && apt install -y git && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/aws-samples/node-js-tests-sample.git .

RUN npm install

FROM build AS test

WORKDIR /app

CMD ["npm", "test"]