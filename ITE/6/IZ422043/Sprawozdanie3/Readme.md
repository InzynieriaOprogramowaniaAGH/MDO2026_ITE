1. Wybór oprogramowania

Wybranym przeze mnie repozytorium jest JestJS - framework do testowania
https://github.com/jestjs/jest

2. Obraz - etap build

> Dockefile.build 
```Dockerfile
FROM node:20
WORKDIR /app
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/jestjs/jest.git .
RUN yarn install
RUN yarn run build
```

Zbudowanie obrazu: `docker build -f Dockerfile.build -t jest-build .`

![Screenshot 1](./1.png)

3. Obraz - etap testów

> Dockefile.test  
```Dockerfile
FROM jest-build

WORKDIR /app

CMD ["npm", "test"]
```

![Screenshot 2](./2.png)

4. Kontener z testami

Uruchomienie: `docker run jest-test`

![Screenshot 3](./3.png)

5. Uruchomienie kontenera w trybie interaktywnym

![Screenshot 4](./4.png)

Kontener jest-test ma sklonowane repozytorium, czyli poprawnie zależy od jest-build