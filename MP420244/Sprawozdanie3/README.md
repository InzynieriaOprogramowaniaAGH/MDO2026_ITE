# 1. Wybór oprogramowania

Do pracy wybrano repozytorium https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example/tree/master. Jest stosunkowo nieduże i idealne do przeprowadzenia testów.

* `git clone https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example.git`
* `cd C-and-Cpp-Tests-with-CI-CD-Example`
* `make`
* `./run_coverage_test.sh` lub `make test`

![Budowanie i testowanie](images/1.%20Budowanie%20i%20testowanie.png)

# 2. Praca z kontenerem

Do uruchomienia kodu z repozytorium nadaje się obraz `gcc:latest`, wyposażony w kompilator C.

* `docker pull gcc:latest`

![Pobieranie obrazu](images/2.%20Pobieranie%20obrazu%20gcc.png)

## Ręczne uruchomienie testów w kontenerze

* `docker run -it gcc:latest`
* `# git clone https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example.git`
* `# cd C-and-Cpp-Tests-with-CI-CD-Example`
* `# make`
* `# ./run_coverage_test.sh` lub `# make test`

![Klonowanie repo wewnątrz kontenera](images/3.%20Klonowanie%20repo%20wewnątrz%20kontenera.png)

![Uruchomienie testu wewnątrz kontenera](images/4.%20Uruchomienie%20testu%20wewnątrz%20kontenera.png)

## Konfiguracja Dockerfile

W pliku budującym należy upewnić się, że środowisko zawiera git-a.

**Treść pliku budującego:**

```
FROM gcc:latest
WORKDIR /app
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example.git
WORKDIR /app/C-and-Cpp-Tests-with-CI-CD-Example
RUN make
```

Plik testujący tylko uruchamia test.

**Treść pliku testującego:**

```
FROM test-repo
WORKDIR /app/C-and-Cpp-Tests-with-CI-CD-Example
CMD ["make", "test"]
```

* `docker build -f Dockerfile.build -t test-repo .`
* `docker build -f Dockerfile.test -t test-repo-test .`

![Tworzenie obrazów z plików Dockerfile](images/5.%20Tworzenie%20kontenerów%20z%20plików%20Dockerfile.png)

Po stworzeniu obrazu plikiem Dockerfile.test możliwe jest uruchomienie testu w kontenerze:

* `docker run --rm test-repo-test`

![Uruchomienie testów w kontenerze](images/6.%20Uruchomienie%20testów%20w%20kontenerze.png)