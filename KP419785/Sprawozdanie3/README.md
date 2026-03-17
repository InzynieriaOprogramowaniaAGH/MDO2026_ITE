# SPRAWOZDANIE 3

1. Repozytorium z kodem dowolnego oprogramowania
Na potrzeby zadania utworzyłam i sklonowałam własne, lekkie repozytorium z programem napisanym w C++. Aby spełnić wymóg otwartości (Open Source), udostępniłam kod publicznie i nadałam mu otwartą licencję MIT. Projekt zawiera Makefile, który pozwala na automatyczne wywołanie procesu budowania (make build) oraz testów jednostkowych (make test).  
![1](<img/Zrzut ekranu 2026-03-16 200251.png>)

   To rozwiązanie wydawało mi się szybsze i wystarczające na potrzeby zajęć. Wielkość pliku również jest bardziej stosowna biorąc na wzgląd mój sprzęt. 

Pobrałam również repozytorium portfinder, dla dodatkowych testów: https://github.com/doganarif/portfinder

2. Instalacja zależności oraz pobranie repozytorium
![2](<img/Zrzut ekranu 2026-03-16 210008.png>)
![3](<img/Zrzut ekranu 2026-03-16 210241.png>)
Dla repozytorium portfinder:
![2.2](<img/Zrzut ekranu 2026-03-17 090036.png>)
![3.2](<img/Zrzut ekranu 2026-03-17 090021.png>)
    sudo apt update && sudo apt install golang-go -y
    git clone https://github.com/doganarif/portfinder.git

3. Uruchomienie procesu build oraz testów
![4.1](<img/Zrzut ekranu 2026-03-16 210401.png>)
![4.2](<img/Zrzut ekranu 2026-03-16 210401.png>)
Dla repozytorium portfinder:
![4.3](<img/Zrzut ekranu 2026-03-17 091603.png>)
![4.4](<img/Zrzut ekranu 2026-03-17 091603.png>)
    make build
    make test

4. Powtórzenie procesu w kontenerze
![5](<img/Zrzut ekranu 2026-03-16 211638.png>)
![6](<img/Zrzut ekranu 2026-03-16 215449.png>)
![7](<img/Zrzut ekranu 2026-03-16 222915.png>)
![8](<img/Zrzut ekranu 2026-03-16 223044.png>)
Dla repozytorium portfinder:
![5.2](<img/Zrzut ekranu 2026-03-17 094310.png>)
![5.3](<img/Zrzut ekranu 2026-03-17 095553.png>)
![5.4](<img/Zrzut ekranu 2026-03-17 095539.png>)
    docker run -it golang:1.24-alpine sh
    apk add git make
    git clone https://github.com/doganarif/portfinder.git

5. Automatyzacja procesu
![9](<img/Zrzut ekranu 2026-03-16 223210.png>)
![10](<img/Zrzut ekranu 2026-03-16 223238.png>)
![11](<img/Zrzut ekranu 2026-03-16 223636.png>)
![12](<img/Zrzut ekranu 2026-03-16 231550.png>)
![13](<img/Zrzut ekranu 2026-03-16 232031.png>)
![14](<img/Zrzut ekranu 2026-03-16 232109.png>)
![15](<img/Zrzut ekranu 2026-03-16 232137.png>)
Dla repozytorium portfinder:
![16](<img/Zrzut ekranu 2026-03-17 085000.png>)
![17](<img/Zrzut ekranu 2026-03-17 085014.png>)
![18](<img/Zrzut ekranu 2026-03-17 095942.png>)
![19](<img/Zrzut ekranu 2026-03-17 091011.png>)
![20](<img/Zrzut ekranu 2026-03-17 094310.png>)
![21](<img/Zrzut ekranu 2026-03-17 105050.png>)
![22](<img/Zrzut ekranu 2026-03-17 105233.png>)
![23](<img/Zrzut ekranu 2026-03-17 105311.png>)

    Po rozwiązaniu drobnych błędów po drodze, automatyzacja przebiegła pomyślnie.
    Utworzono oddzielne pliki Dockerfile dla etapu budowania (build) oraz testów.

6. Użycie Docker Compose
![100](<img/Zrzut ekranu 2026-03-16 232434.png>)
Dla repozytorium portfinder:
![101](<img/Zrzut ekranu 2026-03-17 105448.png>)
![102](<img/Zrzut ekranu 2026-03-17 105514.png>)
![103](<img/Zrzut ekranu 2026-03-17 105535.png>)
Dla repozytorium portfinder:

    Zamiast uruchamiać każdy kontener z osobna w terminalu, użyłam narzędzia Docker Compose, które robi to automatycznie.
    Zbudowłam aplikację, a następnie pomyślnie przeprowadziłam testy.
    Obraz to jedynie statyczny szablon projektu, natomiast kontener to jego uruchomiona, izolowana instancja, w której wykonuje się główny proces.

    docker build -t app-build -f Dockerfile.build .
    docker compose up --build

7. Dyskusja

    1. Program jest prostą aplikacją konsolową. Kontenery sprawdzają się tu bardzo dobrze, ale tylko jako środowisko do budowania i testów. Wdrażanie tego jako stale działającego konteneru nie jest potrzebne, bo nie jest to usługa działająca w tle (np. serwer strony internetowej).
    2. Jeśli program miałby być publikowany jako kontener, wymagany jest Multi-stage build. W ten sposób nie zostanie udostępniony użytkownikom wielki kontener z narzędziami do budowania, a jedynie leciutki obraz z samym plikiem wykonywalnym. 
    3. Zbudowany program najlepiej udostępnić ją użytkownikom jako klasyczny pakiet instalacyjny dla Linux'a.
    4. Zautomatyzować format można tworząc trzeci kontener, który automatycznie użyje narzędzia fpm do wygenerowania instalatora .deb i opublikuje go do sieci.

