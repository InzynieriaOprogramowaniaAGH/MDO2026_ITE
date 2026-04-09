# Sprawozdanie z laboratoriów 1-4: Git, Docker i CI/CD

### 1. Kontrola wersji i środowisko pracy
Git to fundament współczesnego developmentu. 

Zamiast autoryzacji hasłem obecnie stosuje się bezpieczniejsze rozwiązań: klucze SSH zabezpieczone hasłem oraz tokeny PAT.

*   **Środowisko:** Popularnym modelem jest pisanie kodu na maszynie hosta z użyciem GUI i uruchamianie go w izolowanym środowisku uniksowym, synchronizując pliki np. przez Remote-SSH w IDE.
*   **Workflow:** Praca opiera się na gałęziach. Zmiany są wypychane na serwer, a do głównego kodu trafiają poprzez Pull Request. 
*   **Git Hooks:** Lokalna automatyzacja (np. skrypt `commit-msg` w `.git/hooks/`) pozwala na weryfikację logów i kodu jeszcze przed zatwierdzeniem zmian.

### 2. Konteneryzacja - Docker
Docker zapewnia izolację i powtarzalność.

*   **Obrazy i Dockerfile:** Bazy pobiera się z Docker Hub. Konfigurację zapisuje się w pliku `Dockerfile` zgodnie z ideą Infrastructure as Code. Należy dbać o minimalizację warstw i usuwanie cache'u menedżerów pakietów, aby zmniejszyć wagę obrazu.
*   **Zarządzanie:** Środowisko deweloperskie szybko się zaśmieca. Do inspekcji używamy `docker ps -a`, a do czyszczenia zasobów wbudowanych komend sprzątających: `docker container prune` i `docker image prune -a`.

### 3. Powtarzalne procesy budowania
Aby uniezależnić budowanie aplikacji od maszyny hosta, proces ten przenosi się do kontenerów.

*   **Multi-stage build:** Dobrą praktyką jest podział `Dockerfile` na niezależne etapy. Etap Build pobiera zależności i kompiluje kod, a etap Test bazuje na wygenerowanym artefakcie, służąc wyłącznie do uruchomienia testów. Gwarantuje to spójność kodu.
*   **Docker Compose:** Zamiast ręcznego uruchamiania wielu kontenerów, używa się pliku `docker-compose.yml`. Deklaruje się w nim usługi i ich zależności. Uruchomienie i zbudowanie całego wieloetapowego potoku sprowadza się do komendy: `docker compose up --build`.

### 4. Sieci i zarządzanie stanem
Domyślnie kontenery nie zachowują danych po usunięciu.

*   **Stan (Woluminy):** Pliki przechowuje się dzięki mapowaniu lokalnych folderów lub woluminom (np. `-v`). Nowoczesne wersje Dockera pozwalają też na użycie instrukcji `RUN --mount` do tymczasowego dostępu do plików na etapie budowania.
*   **Sieć:** Aby uniknąć łączenia się po uciążliwych adresach IP, tworzy się własne sieci typu bridge. Posiadają one wewnętrzny DNS, dzięki czemu kontenery mogą komunikować się używając swoich nazw, co łatwo przetestować narzędziem iPerf3. Aby usługa była dostępna z zewnątrz, mapuje się porty flagą `-p`.
*   **Serwer SSH w kontenerze:** Instalacja demona `sshd` to zła praktyka łamiąca zasadę jednego procesu na kontener. Powiększa obraz i generuje luki bezpieczeństwa. Zamiast tego używa się `docker exec`. SSH w kontenerze ma sens tylko w specyficznych przypadkach.

### 5. Wdrażanie serwera Jenkins
Jenkins to narzędzie do automatyzacji CI/CD. Instalacja bezpośrednio na systemie operacyjnym jest przestarzała, dziś używa się wersji skonteneryzowanej.

*   **Architektura:** Środowisko składa się z głównego kontenera Jenkins (Controller) oraz pomocniczego kontenera pełniącego rolę demona Dockera. 
*   **Docker-in-Docker (DinD):** Aby Jenkins mógł budować inne obrazy, używa się mechanizmu DinD, który wymaga kontenera uruchomionego w trybie uprzywilejowanym (`privileged: true`).
*   Całość uruchamia się w tle przez `docker compose up -d`, a bezpieczna komunikacja między kontrolerem a demonem Dockera odbywa się po certyfikatach TLS.

### 6. Podsumowanie
Efektywny system CI/CD opiera się na integracji Git-a z narzędziami konteneryzacji. Wykorzystanie Docker Compose, sieci z wewnętrznym DNS oraz wieloetapowego budowania pozwala na stworzenie przenośnego i powtarzalnego środowiska. Zwieńczeniem tej architektury jest skonteneryzowany serwer Jenkins wykorzystujący wzorzec Docker-in-Docker, który automatyzuje cykl życia aplikacji, gwarantując wydajność i bezpieczeństwo kodu.