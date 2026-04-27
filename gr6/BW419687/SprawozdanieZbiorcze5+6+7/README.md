# Laboratorium nr. 5

Celem laboratorium było zapoznanie się z narzędziem Jenkins oraz tworzenie zautomatyzowanych potoków CI/CD (ciągłej integracji i dostarczania) z wykorzystaniem kontenerów Docker.

## Wprowadzono nowe pojęcia:

1. Jenkins - serwer automatyzujący procesy CI/CD. Umożliwia definiowanie zadań (jobów), które kompilują, testują i publikują oprogramowanie. W laboratorium Jenkins działał jako kontener z pomocnikiem DinD (Docker in Docker).

2. Freestyle job - podstawowy typ projektu w Jenkinsie, w którym czynności budowania definiuje się przez GUI, np. poprzez dodanie skryptu powłoki w sekcji Build.

3. Pipeline - zaawansowany typ projektu, w którym cały proces CI definiuje się za pomocą kodu (Jenkinsfile) w języku Groovy. Umożliwia zarządzanie etapami, środowiskami i artefaktami.

4. Agent - węzeł (np. kontener Docker) wykonujący konkretny etap pipeline’a. W laboratorium agentem był obraz flac:builder lub flac:tester.

5. Artefakty - pliki będące wynikiem procesu budowania, np. skompilowane biblioteki, logi testów. Jenkins umożliwia ich archiwizację i publikację (archiveArtifacts).

6. Stash / unstash - mechanizm Jenkinsa do tymczasowego przechowywania plików między etapami (stage) tego samego builda. Pozwalający na współdzielenie plików między agentami (np. w różnych kontenerach).

7. Post-conditions - bloki w pipeline’ie (np. always, success, failure) definiujące akcje wykonywane po zakończeniu etapu lub całego przebiegu, np. czyszczenie workspace’u lub archiwizacja logów.

8. Kontenery Dind - wewnątrz Jenkinsa uruchamiano obrazy flac:builder i flac:tester zbudowane wcześniej za pomocą poleceń Dockera (zapisanych w notatkach).

9. Pipeline syntax - definiowanie potoku w postaci kodu, z możliwością bezpośredniego wklejenia Jenkinsfile.

## Poruszone czynności (w środowisku Jenkins)

1. New Item - tworzenie nowego projektu (freestyle job lub pipeline)

2. Budowanie projektu - ręczne wyzwalanie buildu i obserwacja logów.

# Laboratorium nr. 6

Celem laboratorium było zbudowanie kompletnego pipeline’u CI dla programu otwartoźródłowego (w tym przypadku biblioteki FLAC), obejmującego etapy: pobranie kodu, kompilację, testowanie, instalację (deploy) oraz publikację artefaktów.

## Wprowadzono nowe pojęcia:
1. Etap Collect - zebranie kodu źródłowego programu, tutaj to zwykły git clone.
2. Etap Build - zbudowanie programu za pomocą pobranego kodu źródłowego.
3. Etap Test - testowanie skompilowanego programu załączonymi testami automatycznymi.
4. Etap Deploy - instalacja programu oraz "Smoke Test" czyli test praktyczny programu.
5. Etap Publish - zebranie i udostępnienie gotowych artefaktów.
6. Wersjonowanie - przypisanie unikatowej nazwy danej wersji artefaktu na podstawie np. numeru builda.

# Laboratorium nr. 7

Celem laboratorium było przeniesienie definicji pipeline’u do repozytorium (SCM) oraz potwierdzenie, że cały proces działa wielokrotnie i dostarcza gotową bibliotekę na host.

## Wprowadzono nowe pojęcia:
1. Pipeline z SCM - konfiguracja pipeline występująca razem z pobranym kodem źródłowym, w tym przypadku jenkins pobiera pliki i wyszukuje wśród nich Jenkinsfile z opisem pipeline'a.

2. Definicja gotowości (Definition of Done) - potwierdzenie, że po wykonaniu pipeline’u biblioteka jest rzeczywiście gotowym, funkcjonującym produktem który może zostać pobrany i wykorzystany do przeznaczonego zadania.