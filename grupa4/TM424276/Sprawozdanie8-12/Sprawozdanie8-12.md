# Zbiorowe Sprawozdanie z procesów Automatyzacji i Orkiestracji (Laboratoria 8-12)
 
---

## 1. Laboratorium 8: Automatyzacja infrastruktury za pomocą Ansible

### 1.1. Architektura środowiska i inwentaryzacja
Środowisko oparto na architekturze klient-serwer (bezagentowej), wykorzystując komunikację po protokole SSH i logowanie bezhasłowe (klucze RSA). Skonfigurowano maszynę zarządzającą (DevOps) oraz docelowy węzeł (`ansible-target`). Urządzenia zdefiniowano w pliku inwentaryzacji (`inventory.ini`), z podziałem na grupy logiczne, co pozwala na precyzyjne adresowanie zadań konfiguracyjnych.

### 1.2. Idempotentność i wdrożenie aplikacji (IaC)
Zamiast ręcznej konfiguracji, zastosowano deklaratywne playbooki (YAML). Skrypt zrealizował aktualizację systemu, instalację środowiska Docker oraz uruchomienie kontenera `nginx:alpine`.

**Dlaczego Ansible, a nie skrypty powłoki (Bash)?**
Kluczową przewagą Ansible jest mechanizm **idempotentności**. System ocenia aktualny stan maszyny docelowej przed wykonaniem operacji – jeśli usługa Docker już działa, a kontener jest włączony, Ansible pominie te kroki i nie wywoła niepotrzebnego restartu. Skrypty Bashowe wymusiłyby ponowną instalację lub generowałyby błędy. Ponadto narzędzie natywnie radzi sobie z przerwaniami sieci (status `UNREACHABLE`), nie psując procesu wdrożenia dla pozostałych węzłów.

---

## 2. Laboratorium 9: Instalacja Nienadzorowana (Kickstart)

### 2.1. Automatyzacja instalacji bazowej (Provisioning)
Proces powoływania infrastruktury dla architektury ARM64 zautomatyzowano, eliminując konieczność obsługi interfejsu instalatora systemu Fedora. Użyto pliku odpowiedzi `ks.cfg`, dystrybuowanego w sieci lokalnej przez serwer HTTP. Plik definiował automatyczny podział dysku, listę repozytoriów oraz pakiety bazowe.

### 2.2. Inicjalizacja usług (Sekcja %post)
W ramach skryptu poinstalacyjnego (sekcja `%post`) system został skonfigurowany do pobrania Dockera oraz utworzenia własnej usługi `systemd`. 

**Co daje taka konfiguracja?**
Gwarantuje podejście *Zero-touch provisioning*. Maszyna wirtualna, bezpośrednio po pierwszym uruchomieniu ze świeżo zainstalowanym systemem, samoczynnie ściągała zdefiniowany obraz i uruchamiała kontener aplikacji. Administrator nie musiał logować się na maszynę ani razu, by uzyskać w pełni działające środowisko serwujące stronę WWW.

---

## 3. Laboratoria 10-11: Orkiestracja kontenerów (Kubernetes)

### 3.1. Przejście na architekturę klastrową
Środowisko przeniesiono z samodzielnych demonów Docker do lokalnego klastra Kubernetes (Minikube). Wymagało to zmiany paradygmatu: zamiast zarządzać pojedynczymi kontenerami, steruje się "stanem pożądanym" aplikacji poprzez obiekty `Deployment`. Klaster samoczynnie podtrzymuje zdefiniowaną liczbę replik (Podów) i wystawia je na świat za pomocą obiektów `Service`.

### 3.2. Wdrażanie zmian i strategie aktualizacji
Przetestowano trzy podejścia do wdrażania nowej wersji aplikacji, różniące się czasem niedostępności i wpływem na użytkowników:
* **Recreate:** Ubija wszystkie stare pody przed uruchomieniem nowych. Gwarantuje brak konfliktów, ale powoduje całkowitą przerwę w dostępności usługi (Downtime).
* **Rolling Update (Domyślna):** Aktualizacja rotacyjna. Pody wymieniane są stopniowo, bazując na parametrach nadmiarowości i maksymalnej niedostępności. Zapewnia brak przerw w działaniu (Zero Downtime).
* **Canary Deployment:** Wdrożenie eksperymentalne z użyciem zaawansowanego routingu poprzez etykiety (Labels). Rozdzielono ruch z jednego serwisu tak, że 75% trafiało do wersji stabilnej, a 25% do nowej ("kanarka"). Minimalizuje to ryzyko wpływu krytycznych błędów na wszystkich klientów.

### 3.3. Samoleczenie (Self-healing) i Rollback
Kluczowym testem była symulacja awarii – wdrożenie celowo uszkodzonego obrazu. Nowe pody wpadły w pętlę restartów (`CrashLoopBackOff`), jednak strategia Rolling Update zablokowała wyłączenie starych, stabilnych podów. Wykorzystanie wbudowanej komendy `kubectl rollout undo` pozwoliło na natychmiastowe przywrócenie poprawnej konfiguracji bez najmniejszej przerwy w dostępności usługi dla klienta.

---

## 4. Laboratorium 12: Usługi Kontenerowe (Azure Container Instances)

### 4.1. Architektura Serverless
Środowisko ostatecznie przeniesiono do publicznej chmury Microsoft Azure w modelu CaaS (Container as a Service). Zastosowanie Azure Container Instances pozwoliło na wdrażanie aplikacji z pominięciem jakiegokolwiek zarządzania maszynami wirtualnymi. 

### 4.2. Rozwiązywanie problemów architektury (ARM64 vs AMD64)
Podczas przenoszenia obrazów do chmury napotkano błąd krytyczny – aplikacja kończyła pracę z kodem `ExitCode 1` bez generowania logów (Exec format error).

**Różnica między środowiskiem lokalnym a chmurą:**
Lokalne maszyny na układach Apple kompilowały obrazy domyślnie pod architekturę ARM64. Serwery usługi ACI oczekiwały klasycznych instrukcji x86_64 (AMD64). Platforma Azure nie potrafiła zinterpretować przesłanego pliku binarnego.
Aby rozwiązać problem, zastosowano obejście: pobrano prawidłowy obraz bazowy wymuszając architekturę flagą `--platform linux/amd64`, utworzono z niego kontener wstrzykując własne pliki konfiguracyjne i zapisano jako nową wersję. Artefakt ten poprawnie uruchomił się w chmurze. Udowadnia to, że przenaszalność kontenerów wymaga ścisłego planowania kompilacji skrośnej (Cross-compilation) na etapie budowy (Build).

---

**Podsumowanie:** Cykl laboratoriów pozwolił na praktyczne wdrożenie ewolucji systemów operacyjnych i infrastruktury. Połączenie nienadzorowanej instalacji (Kickstart) z automatyzacją konfiguracji (Ansible) zminimalizowało ręczną pracę administracyjną. Zastosowanie Kubernetes zapewniło wysoką dostępność (HA) i bezpieczne aktualizacje aplikacji (Canary/Rolling Update), podczas gdy wdrożenie na Azure ACI udowodniło korzyści płynące z elastycznej, bezserwerowej chmury, podkreślając jednocześnie znaczenie znajomości różnic architektonicznych między procesorami.