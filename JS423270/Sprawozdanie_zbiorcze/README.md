# Sprawozdanie zbiorcze z laboratoriów DevOps

1. Wstęp

W tym sprawozdaniu streszczono cykl zajęciowy lab 1 - lab 4, skupiając się na analizie i wnioskach, aniżeli samym wykonaniu.

2. Zarządzanie kodem i bezpieczeństwo (Git & SSH)

Prace rozpoczęto od zabezpieczenia dostępu do zdalnych zasobów. Zrezygnowano z tradycyjnego uwierzytelniania hasłem na rzecz protokołu SSH.

- Klucze kryptograficzne: Wygenerowano i wdrożono klucze typu ED25519/ECDSA, które charakteryzują się większym bezpieczeństwem i wydajnością niż starsze standardy.
- Wieloskładnikowe uwierzytelnianie: Włączono mechanizm 2FA, co zabezpiecza repozytorium przed nieautoryzowanym dostępem nawet w przypadku wycieku danych logowania.
- Automatyzacja standardów (Git Hooks): Wprowadzono skrypt commit-msg działający po stronie klienta. Skrypt ten, wykorzystując narzędzia strumieniowe (np. sed), automatycznie weryfikuje strukturę wiadomości commita pod kątem zgodności z wymaganiami projektowymi (prefix z inicjałami i numerem indeksu). Rozwiązanie to pozwala na utrzymanie wysokiej czytelności historii zmian w systemie kontroli wersji.

3. Izolacja i architektura kontenerowa (Docker)

W kolejnym etapie przeanalizowano działanie silnika Docker jako alternatywy dla ciężkich maszyn wirtualnych.

- Mechanizm izolacji: Przeanalizowano działanie przestrzeni nazw (namespaces) poprzez porównanie identyfikatorów procesów (PID). Zauważono, że główny proces wewnątrz kontenera posiada PID 1, podczas gdy na systemie operacyjnym hosta jest on widziany jako proces o standardowym, wysokim numerze identyfikacyjnym. Potwierdza to, że konteneryzacja opiera się na separacji procesów w obrębie tego samego jądra systemu.
- Dobór środowisk bazowych: Przetestowano obrazy różnych dystrybucji (Ubuntu, Alpine, Fedora) pod kątem ich rozmiaru i dostępności narzędzi. Wyciągnięto wniosek, że obrazy typu slim lub Alpine są optymalne dla środowisk produkcyjnych ze względu na minimalny narzut, podczas gdy obrazy pełne lepiej sprawdzają się w fazie budowania oprogramowania.

4. Budowanie oprogramowania w modelu CI (Continuous Integration)

Skonfigurowano kontenery jako dedykowane środowiska do kompilacji i testowania kodu, co zapewnia pełną przenośność procesów.

- Podejście Multi-stage Build: Zastosowano technikę wieloetapowego budowania obrazów. W pierwszym etapie (build) wykorzystano kontener z pełnym zestawem kompilatorów i zależności, natomiast w drugim etapie (run) przeniesiono jedynie gotowy artefakt (np. plik wykonywalny) do lekkiego obrazu. Pozwala to na drastyczne zmniejszenie rozmiaru końcowego obrazu i poprawę bezpieczeństwa poprzez usunięcie zbędnych narzędzi (np. Git, Make).
- Orkiestracja za pomocą Docker Compose: Zamiast manualnego zarządzania pojedynczymi kontenerami, wdrożono pliki docker-compose.yml. Umożliwiło to definiowanie całych stosów technologicznych (aplikacja + baza danych + sieć) w formie deklaratywnej, co upraszcza proces wdrażania środowisk deweloperskich.

5. Sieci, persystencja i automatyzacja (Jenkins)

Ostatnia faza prac dotyczyła zaawansowanej konfiguracji sieciowej i wdrożenia serwera automatyzacji Jenkins.

- Zarządzanie danymi (Volumes): Przetestowano mechanizmy named volumes oraz bind mounts. Zastosowanie woluminów pozwoliło na trwałe przechowywanie konfiguracji i logów Jenkinsa, dzięki czemu dane nie są tracone po usunięciu kontenera.
- Wydajność sieciowa: Przeprowadzono testy przepustowości za pomocą narzędzia iperf3 wewnątrz izolowanej sieci typu bridge. Uzyskany wynik na poziomie ok. 29.3 Gbits/sec wykazuje minimalny wpływ stosu sieciowego Dockera na wydajność komunikacji międzyusługowej. Wykorzystano również mechanizm wewnętrznego DNS Dockera, co pozwala na łączenie się z usługami za pomocą ich nazw, a nie zmiennych adresów IP.
- Architektura Docker-in-Docker (DinD): Zestawiono serwer Jenkins w taki sposób, aby mógł on zarządzać procesami Dockerowymi na poziomie agenta. Rozwiązanie to oparto na komunikacji z kontenerem pomocniczym docker:dind, co pozwala Jenkinsowi na budowanie obrazów i uruchamianie kontenerów testowych w sposób odizolowany od głównego serwera CI.

6. Podsumowanie i wnioski

Zrealizowane laboratoria pozwoliły na praktyczne opanowanie narzędzi kluczowych w nowoczesnym cyklu wytwarzania oprogramowania. Zastosowanie konteneryzacji i automatyzacji prowadzi do:

- Eliminacji błędów środowiskowych: Dzięki Dockerfile proces budowania jest zawsze identyczny.
- Zwiększenia bezpieczeństwa: Izolacja usług i stosowanie bezpiecznych metod uwierzytelniania (SSH/2FA) minimalizuje ryzyko naruszenia systemu.
- Optymalizacji wydajności: Kontenery oferują niemal natywną wydajność sieciową i procesową przy zachowaniu pełnej separacji.

Wdrożone rozwiązania stanowią solidną podstawę do budowy zaawansowanych potoków CD (Continuous Deployment) w środowiskach rozproszonych.