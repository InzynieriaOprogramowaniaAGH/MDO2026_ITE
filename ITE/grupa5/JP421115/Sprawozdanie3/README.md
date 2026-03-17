# Sprawozdanie 3

Autor: Jan Pawelec

## Proste operacje
Wybrano cJSON - otwartoźródłowe repo spod linku: [cJSON](https://github.com/DaveGamble/cJSON)

### Klonowanie repozytorium

![alt text](0_clone_repo.png)

### Build programu

![alt text](0_cmake_build.png)

### Test programu

![alt text](0_test.png)

## Kontener
Poniższe opreacje pracy z programem wykonano na kontenerze.

### Uruchomienie kontenera

![alt text](1_container_start.png)

### Build na kontenerze

![alt text](1_maszyna_make.png)

### Uruchomienie testu na kontenenerze

![alt text](1_maszyna_test.png)

## Dockerfile
Skompresowano operacje z powyższego rozdziału do Dockerfile. W folderze znajdują się kody źródłowe obu programów.

### Obraz do budowania

![alt text](2_dockerfile_build.png)

### Obraz do testów

![alt text](2_dockerfile_test.png)

### Uruchomienie testów

![alt text](2_test_passed.png)

## Docker compose
Na koniec zamknięto proces w kompozycję. 

### Kod 

![alt text](3_docker_compose.png)

### Uruchomienie testów przez compose

![alt text](3_docker_compose_efekt.png)


## Dyskusja

1) Rzeczony program jest w zasadzie biblioteką. Budowanie go w kontenerze jest wysoce rozsądne, jednak nie ma sensu go wdrażać. Gdyby jakieś API korzystało z jego funkcjonalności, wtedy jak najbardziej możnaby wdrażać i publikować jako kontener.
2) Absolutną koniecznością jest oczyszczenie artefaktu po buildzie, stąd popularność multi-stage build, gdzie z pierwszej części wyciągana jest tylko gotowa binarka.
3) Dedykowana ścieżka to świetne rozwiązanie, gdyż pozwala rozdzielić build od publikacji. W drugiej fazie można zadecydować o formacie dystrybucji, nie zanieczyszczając repo źródłowego.
4) W przypadku cJSON dystrybucja jako pakiet to najlepszy kierunek.
5) Powyższy format można zapewnić np. tworząc trzeci kontnener, w którym dojdzie do spakowania. Operacja mogłaby się kończyć pakowaniem do .zip, .deb etc.