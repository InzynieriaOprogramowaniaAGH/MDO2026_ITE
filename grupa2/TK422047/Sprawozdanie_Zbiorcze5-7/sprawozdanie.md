# Sprawozdanie Zbiorcze lab 5-7  Tomasz Kamiński


## Jenkins wstęp 

Jenkins to open-source narzędzie automatyzacji, które służy do implementacji procesów Continuous Integration (CI) i Continuous Delivery (CD) w projektach oprogramowania. Pozwala na automatyzację różnych etapów rozwoju oprogramowania, takich jak budowanie, testowanie i wdrażanie kodu, co przyspiesza i usprawnia procesy DevOps.


## Laboratorium 5 

Głównym celem laboratoratorium była konfiguracja i zapoznanie z Jenkinsem

Zakres ćwiczenia: 

* utworzenie sieci Docker jenkins
* uruchomienie kontera jenkins dind
* zbudowanie własnego obrazu myjenkins-blueocean
* dodanie wtyczki dockera 
* Utworzenie dwoch projektow frestyle oraz napisanie pipline 
  * Wyświetlający -uname
  * Zwracający bład gdy godzina jest nieparzysta
  * Pipline, który pobierał repo z kodem, przechodził na wskazaną gałąź i budował obraz 
* ponowne uruchomienie pipline'u


## Laboratorium 6 

Głównym celem zajęć było zaprojektowanie i implementacja kompletnego, zautomatyzowanego pipeline CI/CD dla wybranej aplikacji/biblioteki (w tym przypadku hiredis). 


 Opis działania pipline'u
#### 1) Czyszenie środowiska 
* Usunięcie starego kontenera hiredis-produkcja i wyczyszczenie workspace Jenkinsa.
#### 2) Klonowanie repozytorium zajęciowego
* Jenkins pobiera repozytorium MDO2026_ITE z gałęzi TK422047 i klonuje repozytorium hiredis.
#### 3) Build
* Budowany jest obraz hiredis-build, zawierający zbudowaną bibliotekę hiredis.
#### 4) Test
* Budowany jest obraz hiredis-test, oparty o obraz build. Następnie uruchamiane są testy.
#### 5) Deploy image
* Budowany jest obraz hiredis-deploy, oparty o obraz build.
#### 6) Wdrożenie
* Jenkins uruchamia kontener hiredis-produkcja na podstawie obrazu deploy.
#### 7) Smoke test
* Sprawdzane jest, czy kontener działa oraz czy zawiera plik libhiredis.so.
#### 8) Publikacja artefaktu
* Tworzony jest artefakt .tar.gz zawierający raport, commit oraz logi. Artefakt jest publikowany w Jenkinsie.

W projekcie nie zdecydowano się na tworzenie forka repozytorium aplikacji. Repozytorium hiredis jest klonowane bezpośrednio z oficjalnego źródła, ponieważ pipeline nie wymaga wprowadzania zmian w kodzie aplikacji.

Diagram UML

![](image2.png)


## Laboratorium 7 

Celem laboratorium było rozwinięcie pipline bazując na tym z poprzednich zajęć i jego pełna integracja z gitem oraz serwerem Jenkins. Proces rozpoczęto od konfiguracji zadania w trybie „Pipeline script from SCM”, co pozwoliło na dynamiczne pobieranie skryptu bezpośrednio z pliku Jenkinsfile znajdującego się w repozytorium GitHub. Dzięki zastosowaniu komendy checkout scm, serwer automatycznie synchronizował kod źródłowy biblioteki hiredis do czystej przestrzeni roboczej przy każdym uruchomieniu builda. Kluczowym elementem weryfikacji był etap Sandbox, w którym nowo utworzony kontener przechodził testy uruchomieniowe w izolowanym środowisku.