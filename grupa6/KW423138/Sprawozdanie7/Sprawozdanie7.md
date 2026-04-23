# Sprawozdanie - zajęcia 7

- [x] Przepis dostarczany z SCM, a nie wklejony w Jenkinsa lub sprawozdanie (co załatwia nam `clone` )

Pipeline został zdefiniowany w pliku Jenkinsfile znajdującym się w repozytorium Git, co umożliwia traktowanie procesu CI/CD jako "infrastructure as code".
Tak jak widać Pipline nie jest wklejony, ale Jenkins pobiera go z repo:

![1](obrazyLab6/1.png)

- [x] Posprzątaliśmy i wiemy, że odbyło się to skutecznie - mamy pewność, że pracujemy na najnowszym (a nie *cache'owanym* kodzie)

Log:

**Fetching changes from the remote Git repository**
**Checking out Revision ...**

Jenkins pobiera świeży kod z Git → NIE używa starego workspace

Każde uruchomienie pipeline rozpoczyna się od pobrania aktualnego kodu z repozytorium, co eliminuje ryzyko pracy na cache’owanych danych.

Wszystkie logi są dostępne w pliku console-logs w folderze Sprawozdanie6.
- [x] Etap `Build` dysponuje repozytorium i plikami `Dockerfile`

```dockerfile
FROM node:20 AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM node:20
WORKDIR /app
COPY --from=builder /app .
CMD ["npm", "run", "start"]
```
Zastosowano podejście multi-stage build, gdzie pierwszy etap (BLDR) odpowiada za budowanie aplikacji, a drugi za przygotowanie lekkiego obrazu deployowego.

- [x] Etap `Build` tworzy obraz buildowy, np. `BLDR`
- [x] Etap `Build` (krok w tym etapie) lub oddzielny etap (o innej nazwie), przygotowuje artefakt - **jeżeli docelowy kontener ma być odmienny**, tj. nie wywodzimy `Deploy` z obrazu `BLDR`

-> Mój artefakt, to obraz Docker **megakacper22/nest-app:latest** - artefaktem procesu CI/CD jest obraz Dockera zawierający zbudowaną aplikację.

- [x] Etap `Test` przeprowadza testy 

-> W pliku Jenkinsfile jest linijka *npm run test*

- [x] Etap `Deploy` przygotowuje **obraz lub artefakt** pod wdrożenie. W przypadku aplikacji pracującej jako kontener, powinien to być obraz z odpowiednim entrypointem. W przypadku buildu tworzącego artefakt niekoniecznie pracujący jako kontener (np. interaktywna aplikacja desktopowa), należy przesłać i uruchomić artefakt w środowisku docelowym.
- [x] Etap `Deploy` przeprowadza wdrożenie (start kontenera docelowego lub uruchomienie aplikacji na przeznaczonym do tego celu kontenerze sandboxowym)

-> w logach konsoli mam:
```docker run -d -p 3000:3000 --name nest-app ...```

Etap Deploy uruchamia kontener aplikacji w środowisku Docker, co stanowi test wdrożeniowy (smoke test).

- [x] Etap `Publish` wysyła obraz docelowy do Rejestru i/lub dodaje artefakt do historii builda

```docker push megakacper22/nest-app:latest```
Obraz aplikacji jest publikowany w Docker Hub, co umożliwia jego ponowne użycie i wdrożenie w innych środowiskach.

- [x] Ponowne uruchomienie naszego *pipeline'u* powinno zapewniać, że pracujemy na najnowszym (a nie *cache'owanym*) kodzie. Innymi słowy, *pipeline* musi zadziałać więcej niż jeden raz 😎

Pipeline jest powtarzalny – każde jego uruchomienie tworzy środowisko od nowa, co gwarantuje brak zależności od poprzednich buildów.

![2](obrazyLab6/2.png)
![4](obrazyLab6/4.png)
![3](obrazyLab6/3.png)

### Czy opublikowany obraz może być pobrany z Rejestru i uruchomiony w Dockerze bez modyfikacji (acz potencjalnie z szeregiem wymaganych parametrów, jak obraz DIND)? Nie chcemy posyłać w świat czegoś, co działa tylko u nas!

Artefakt końcowy (obraz Docker) jest w pełni deployowalny i może zostać uruchomiony w dowolnym środowisku zgodnym z Dockerem.

```docker run -p 3000:3000 megakacper22/nest-app:latest```

### Czy dołączony do jenkinsowego przejścia artefakt, gdy pobrany, ma szansę zadziałać od razu na maszynie o oczekiwanej konfiguracji docelowej?

Tak - z logów wiemy, że obraz został zbudowany, wypchnięty do rejestru i został uruchomiony, a to oznacza:

 - obraz zawiera wszystko (Node, zależności, build)
 - ma poprawny entrypoint (npm run start)
 - nie wymaga ręcznej konfiguracji

Logi:
```
docker build -t megakacper22/nest-app:latest .
docker push megakacper22/nest-app:latest
docker run -d -p 3000:3000 --name nest-app megakacper22/nest-app:latest
```
 Czyli ktoś inny (na innej maszynie) może wywołać:
```
docker run megakacper22/nest-app:latest
```

