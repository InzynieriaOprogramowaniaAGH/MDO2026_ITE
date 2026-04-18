# Pipeline script

Skrypt pipeline usługi Jenkins zdecydowanie ułatwia zarządzanie procesem rozwijania oprogramowania. Dzięki niemu można zautomatyzować dużą ilość etapów produkcji, takich jak np. budowanie, testowanie i publikowanie, co sprowadza szereg operacji manualnego wdrażania kodu do jednego uruchomienia rurociągu.

Na potrzeby ćwiczeń przygotowano prosty skrypt, wykonujący wszystkie wypisane poniżej czynności:

- [x] clone
- [x] build
- [x] test
- [x] package
- [x] deploy
- [x] publish

W skrypcie panuje uporządkowana struktura. Najpierw definiowane są zmienne środowiskowe. Potem opisane są kroki, z których każdy definiuje własnego agenta i wywołuje polecenia. Na końcu skryptu został umieszczony blok 'post' jako przykład czynności zamykających wykonanie pipeline.

## Clone

Ten krok kopiuje do pipeline'a repozytorium z GitHub'a:

`git branch: "${BRANCH}", url: "${REPO_URL}"`

![Clone](images/1.%20Clone.png)

## Build

Krok budujący wykorzystuje kontener do zbudowania programu. Wybrany został przykładowy projekt, stworzony do testowania CI/CD. Budowanie odbywa się przez pojedyncze wywołanie 'make':

`sh 'make'`

![Build](images/2.%20Build.png)

## Test

Krok testujący również przebiega w kontenerze. Polega on na wywołaniu 'make test' odpowiedzialnego za testy i umieszczeniu wyników w pliku tekstowym:

`sh 'make test > test-results.txt 2>&1'`

![Test](images/3.%20Test.png)

## Package

Krok paczkujący umieszcza zbudowany projekt w archiwum tar:

```
sh '''
mkdir -p ${BUILD_DIR}
make
tar -czf ${ARTIFACT} *
'''
```

![Package](images/4.%20Package.png)

## Deploy

Krok wdrażający symuluje budowanie i testowanie projektu w nowym kontenerze:

```
sh '''
make clean
make
./test-library.out
'''
```

![Deploy](images/5.%20Deploy.png)

## Publish

Krok publikujący zapisuje archiwum jako artefakt:

`archiveArtifacts artifacts: "${ARTIFACT}", fingerprint: true`

![Artifacts](images/10.%20Artifacts.png)

Na końcu czyści przestrzeń roboczą:

```
post {
    always {
        cleanWs()
    }
}
```

![Publish](images/6.%20Publish.png)

## Post actions

Ostatni krok wypisuje odpowiedni komunikat w zależności od sukcesu pipeline'a:

```
post {
    success {
        echo 'Pipeline completed successfully!'
    }
    failure {
        echo 'Pipeline failed!'
    }
}
```

![Post actions](images/7.%20Post%20Actions.png)

## Podsumowanie

![](images/8.%20Build%20status.png)