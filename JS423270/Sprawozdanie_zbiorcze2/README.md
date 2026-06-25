# Sprawozdanie zbiorcze z zajęć 5-7

## 1. Architektura Konteneryzacji (Docker i DinD)

Fundamentem całego omawianego ekosystemu jest technologia konteneryzacji oparta na platformie Docker. Zapewnia ona powtarzalność, przenośność oraz ścisłą izolację poszczególnych etapów cyklu życia oprogramowania.

- **Docker in Docker (DinD):** Środowisko budujące opiera się na instancji Dockera eksponującej środowisko zagnieżdżone. Pozwala to kontenerowi nadrzędnemu (np. serwerowi CI) na bezpieczne tworzenie, uruchamianie i zarządzanie kontenerami potomnymi wewnątrz własnej izolowanej przestrzeni.
    
- **Izolacja odpowiedzialności kontenerów:** Technologia wymusza stosowanie dedykowanych obrazów do konkretnych zadań. Środowisko dzieli się na wyspecjalizowane byty:
    
    - **Obrazy bazowe i zależności (Builder):** Kontenery wyposażone w narzędzia deweloperskie i biblioteki niezbędne do kompilacji kodu (tzw. _runtime dependencies_). Narzędzie to promuje świadome używanie konkretnych tagów wersji zamiast domyślnego `latest`.
        
    - **Obrazy testowe (Tester):** Kontenery wywodzące się z obrazu budującego, dedykowane wyłącznie do uruchamiania zautomatyzowanych testów oraz generowania logów z tego procesu.
        
    - **Obrazy wdrożeniowe (Deploy):** Zoptymalizowane kontenery docelowe lub integracyjne (np. oparte na dystrybucjach typu `slim`, jak `node-slim`), pozbawione zbędnych zależności narzędziowych, w których aplikacja ostatecznie pracuje lub przechodzi _smoke test_.
        

## 2. Orkiestracja Potoków i "Infrastructure as Code" (Jenkins)

Centralnym punktem automatyzacji jest Jenkins, pełniący rolę serwera ciągłej integracji i ciągłego wdrażania (CI/CD). Integracja z nowoczesnymi interfejsami, takimi jak rozszerzenie Blueocean, pozwala na wizualizację przepływu zadań.

- **Podejście Deklaratywne (Pipeline as Code):** Konfiguracja potoku nie jest przetrzymywana w interfejsie graficznym narzędzia, lecz przyjmuje formę deklaratywnego pliku `Jenkinsfile`. Dzięki temu sama infrastruktura budowania staje się częścią kodu źródłowego aplikacji (abstrakcja "Infrastructure as Code").
    
- **Integracja z SCM (Source Control Management):** Silnik potoków komunikuje się bezpośrednio z systemami kontroli wersji (np. Git), skąd pobiera najnowszy kod aplikacji oraz to, jak ma ją zbudować.
    
- **Ścieżka krytyczna (Critical Path):** Technologia ta umożliwia modelowanie zautomatyzowanych przepływów obejmujących kluczowe etapy: wyzwolenie budowy (_commit_/_trigger_), klonowanie repozytorium (_clone_), kompilację (_build_), weryfikację jakości (_test_), uruchomienie (_deploy_) oraz publikację (_publish_).
    

## 3. Zarządzanie Artefaktami, Formaty i Dystrybucja

Wynikiem działania technologii CI/CD musi być zawsze wersjonowany i gotowy do wdrożenia zasób (artefakt), którego pochodzenie można jednoznacznie zidentyfikować.

- **Formy redystrybucyjne:** W zależności od specyfiki aplikacji, technologiami docelowymi zapisu mogą być przenośne formaty binarne lub archiwa (m.in. pakiety RPM/DEB, archiwa tar.gz, pakiety NuGet/NPM, pliki JAR, środowiska Flatpak).
    
- **Rejestry i Wersjonowanie:** Zarządzanie gotowymi paczkami oraz obrazami kontenerów z odpowiednimi punktami wejścia (_entrypoint_) odbywa się poprzez publikację do dedykowanych rejestrów online (Registry). Sam proces identyfikacji artefaktów opiera się na systematycznym nazewnictwie, w tym na podejściu opartym o _semantic versioning_ (wersjonowanie semantyczne).
    

## 4. Zarządzanie Konfiguracją (Ansible i Architektura Bezagentowa)

Kolejną warstwą technologiczną jest oprogramowanie Ansible, reprezentujące mechanizmy zarządzania konfiguracją maszyn wirtualnych.

- **Architektura bezagentowa:** Technologia ta nie wymaga instalacji dedykowanego oprogramowania na węzłach docelowych (_ansible-target_). Do komunikacji między węzłem głównym a docelowym wykorzystywany jest standardowy serwer OpenSSH (`sshd`) oraz podstawowe narzędzia systemowe (np. `tar`).
    
- **Uwierzytelnianie:** Aspekt bezpieczeństwa i automatyzacji realizowany jest poprzez asymetryczną kryptografię – wymianę kluczy SSH pomiędzy użytkownikami w celu umożliwienia bezhasłowego logowania.
    
- **Lekkość zasobów i stabilność stanu:** Zarządzanie flotą opiera się na dążeniu do jak najmniejszego zbioru zainstalowanego oprogramowania na maszynach docelowych oraz stosowaniu narzędzi wirtualizacyjnych (jak eksport i migawki stanu maszyny) dla zabezpieczenia bazowej konfiguracji.
    

## 5. Abstrahowanie Architektury (UML)

Przed właściwą implementacją technologiczną, procesy CI/CD oraz infrastruktura są modelowane wizualnie przy użyciu języka UML (Unified Modeling Language). Technologia ta obejmuje:

- **Diagramy Aktywności:** Do zdefiniowania przepływu sterowania pomiędzy etapami (_collect_, _build_, _test_, _report_).
    
- **Diagramy Wdrożeniowe:** Do udokumentowania topologii fizycznej i logicznej, ukazując relacje między serwerami (zasobami), kontenerami (składnikami) i wynikowymi pakietami (artefaktami).