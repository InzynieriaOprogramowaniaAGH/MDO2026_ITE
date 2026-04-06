**Sprawozdanie z zajęć – Git, Docker, CI/CD (Zajęcia 01–04)**
=============================================================

**1\. Wprowadzenie**
--------------------

Celem cyklu zajęć było przygotowanie środowiska pracy oraz zdobycie praktycznych umiejętności związanych z systemem kontroli wersji Git, konteneryzacją przy użyciu Dockera oraz podstawami systemów CI/CD na przykładzie Jenkinsa. Kolejne zajęcia rozwijały kompetencje od konfiguracji narzędzi, przez budowę środowisk kontenerowych, aż po automatyzację procesów budowania i testowania oprogramowania.

**2\. Zajęcia 01 – Git, SSH, Gałęzie**
--------------------------------------

Pierwsze zajęcia skupiały się na przygotowaniu środowiska pracy oraz poznaniu podstaw systemu Git i uwierzytelniania SSH.

### **Zrealizowane zadania**

*   Instalacja Git oraz konfiguracja środowiska (Linux/VM)
*   Klonowanie repozytorium:
    *   przez HTTPS (z użyciem Personal Access Token)
    *   przez SSH (po konfiguracji kluczy)
*   Utworzenie dwóch kluczy SSH (innych niż RSA, np. ed25519), w tym jednego zabezpieczonego hasłem
*   Konfiguracja uwierzytelniania dwuskładnikowego (2FA) na GitHubie
*   Integracja repozytorium z IDE (np. Visual Studio Code)
*   Konfiguracja przesyłania plików (np. FileZilla / eksplorator plików)
    

### **Praca z gałęziami**

*   Przełączanie między gałęziami (main, gałąź grupowa)
*   Utworzenie własnej gałęzi (inicjały + nr indeksu)
*   Praca w dedykowanym katalogu użytkownika
    

### **Git hook**

Stworzono skrypt wymuszający format komunikatów commitów.
Hook został umieszczony w .git/hooks/commit-msg i automatycznie sprawdzał poprawność commitów.

### **Wnioski**

*   Git umożliwia efektywne zarządzanie kodem i współpracę zespołową
*   SSH zwiększa bezpieczeństwo i wygodę pracy
*   Git hooki pozwalają wymuszać standardy pracy
    

**3\. Zajęcia 02 – Docker (podstawy)**
--------------------------------------

Celem zajęć było wprowadzenie do konteneryzacji i uruchamiania środowisk w Dockerze.

### **Zrealizowane zadania**

*   Instalacja Dockera (preferowane pakiety systemowe)
*   Rejestracja w Docker Hub
*   Praca z obrazami:
    *   hello-world
    *   busybox
    *   ubuntu / fedora
    *   mariadb, .NET runtime/sdk
*   Uruchamianie kontenerów i sprawdzanie:
    *   rozmiaru obrazów
    *   kodu wyjścia
*   Praca z kontenerem busybox:
    *   tryb interaktywny
    *   sprawdzenie wersji
*   Uruchomienie pełnego systemu w kontenerze:
    *   analiza procesów (PID 1)
    *   aktualizacja pakietów
        

### **Dockerfile**

Stworzono własny obraz:

*   bazujący na systemie Linux
*   instalujący Git
*   klonujący repozytorium
    

**Przykład:**

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`FROM ubuntu:latestRUN apt-get update && apt-get install -y gitWORKDIR /appRUN git clone` 

### **Zarządzanie zasobami**

*   listowanie kontenerów
*   usuwanie zakończonych kontenerów
*   czyszczenie obrazów
    

### **Wnioski**

*   Docker umożliwia szybkie tworzenie izolowanych środowisk
*   Kontenery są lekkie i przenośne
*   Dockerfile pozwala automatyzować konfigurację środowiska
    

**4\. Zajęcia 03 – Dockerfile i CI (build + test)**
---------------------------------------------------

Celem było stworzenie powtarzalnego środowiska budowania i testowania aplikacji.

### **Zrealizowane zadania**

*   Wybór projektu open-source (z testami i systemem build)
*   Lokalny build i testy
*   Powtórzenie procesu w kontenerze
    

### **Budowanie w kontenerze**

*   wybór odpowiedniego obrazu (np. node, ubuntu)
*   instalacja zależności
*   uruchomienie builda i testów
    

### **Automatyzacja – Dockerfile**

Utworzono dwa obrazy:

#### **1\. Build**

*   instalacja zależności
*   budowanie aplikacji
    

#### **2\. Test**

*   bazuje na obrazie build
*   uruchamia testy
    

**Kluczowa koncepcja:** kontener jako etap pipeline’u CI

### **Wnioski**

*   Kontenery zapewniają powtarzalność środowiska
*   Oddzielenie build/test zwiększa przejrzystość procesu
*   Docker może pełnić rolę podstawy CI/CD
    

**5\. Zajęcia 04 – Zaawansowany Docker i Jenkins**
--------------------------------------------------

### **Woluminy i trwałość danych**

*   konfiguracja woluminów wejściowych i wyjściowych
*   udostępnianie danych między kontenerami
    

**Metody:**

*   bind mount
*   docker volumes
*   kopiowanie danych
    

### **Build z woluminami**

*   kod źródłowy na woluminie wejściowym
*   wynik builda na woluminie wyjściowym
    

### **Sieci i komunikacja**

*   uruchomienie iperf3 w kontenerze
*   komunikacja między kontenerami:
    *   przez IP
    *   przez nazwę (custom network)
*   test przepustowości
    

### **Usługi w kontenerach**

*   uruchomienie SSHD w kontenerze
*   połączenie z kontenerem przez SSH
    

**Zalety:**

*   łatwy dostęp do kontenera
*   możliwość debugowania
    

**Wady:**

*   naruszenie idei “jedna usługa = jeden kontener”
*   większa powierzchnia ataku
    

### **Jenkins (CI/CD)**

*   uruchomienie Jenkinsa w Dockerze
*   konfiguracja Docker-in-Docker (DIND)
*   inicjalizacja systemu
*   dostęp przez przeglądarkę
    

### **Wnioski**

*   Woluminy umożliwiają trwałość danych
*   Sieci Dockera pozwalają na komunikację usług
*   Jenkins automatyzuje proces CI/CD
*   Kontenery są fundamentem nowoczesnych pipeline’ów
    

**6\. Podsumowanie**
----------------------------

Podczas zajęć zdobyto praktyczne umiejętności w zakresie:

*   pracy z systemem kontroli wersji Git
*   bezpiecznej autoryzacji (SSH, 2FA)
*   tworzenia i zarządzania kontenerami Docker
*   budowania środowisk CI/CD
*   automatyzacji procesów (build, test)
*   konfiguracji sieci i woluminów
*   uruchamiania systemów CI (Jenkins)
