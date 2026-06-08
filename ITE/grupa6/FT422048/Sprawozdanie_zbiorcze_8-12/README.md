# Sprawozdanie Zbiorcze (Laboratoria 8 - 12)

**Imię i Nazwisko:** Franciszek Tokarek  
**Numer albumu:** FT422048  

---

## Podsumowanie wykonanych prac (Technologie DevOps)
Niniejsze sprawozdanie stanowi agregację wiedzy i zrealizowanych zadań z zakresu automatyzacji infrastruktury, wdrożeń nienadzorowanych, orkiestracji kontenerów oraz usług chmurowych.

### [Laboratorium 8: Automatyzacja konfiguracji (Ansible)](../Sprawozdanie8)
* Skonfigurowano bezhasłowe połączenia SSH i pliki inwentaryzacji (Inventory).
* Wykorzystano playbooki do zautomatyzowania konfiguracji serwera (aktualizacje `apt`, przesyłanie plików, restart usług).
* Udowodniono **idempotentność** narzędzia Ansible (brak niepotrzebnych zmian przy ponownym uruchomieniu).
* Wdrożono skonteneryzowaną aplikację (Redis) przy użyciu strukturalnej Roli Ansible (`ansible-galaxy`).

### [Laboratorium 9: Instalacja nienadzorowana (Kickstart)](../Sprawozdanie9)
* Stworzono plik odpowiedzi (`anaconda-ks.cfg`) automatyzujący pełen proces instalacji systemu Fedora Server 44 (partycjonowanie, konfiguracja źródeł, instalacja pakietów).
* Zautomatyzowano wdrożenie środowiska Docker oraz autostart kontenera usługi Redis przy użyciu skryptu w sekcji `%post`.
* Wykorzystano wirtualny nośnik ISO `OEMDRV` do wstrzyknięcia konfiguracji do instalatora.
* *Uwaga: Zidentyfikowano i opisano ograniczenia hipernadzorcy Parallels Desktop dla architektury ARM64.*

### [Laboratorium 10: Zarządzanie kontenerami (Kubernetes cz. 1)](../Sprawozdanie10)
* Uruchomiono i skonfigurowano lokalny klaster **Minikube** (z zachowaniem limitów zasobów sprzętowych).
* Wdrożono kontener Redis w sposób imperatywny (`kubectl run`).
* Zastąpiono wdrożenie ręczne architekturą **Infrastructure as Code (IaC)**, wykorzystując pliki YAML do stworzenia skalowalnego obiektu `Deployment` (4 repliki) oraz usługi sieciowej `Service`.

### [Laboratorium 11: Zarządzanie kontenerami (Kubernetes cz. 2)](../Sprawozdanie11)
* Przećwiczono pełny cykl życia aplikacji: dynamiczne skalowanie, wprowadzanie błędnych wersji obrazu oraz wycofywanie wdrożeń (Rollback).
* Wykorzystano własny skrypt powłoki (Bash) automatyzujący sprawdzanie statusu wdrożenia (`rollout status`).
* Zaimplementowano trzy zaawansowane strategie wdrożeniowe:
  * **Recreate:** Pełen restart środowiska.
  * **Rolling Update:** Bezprzerwowa aktualizacja replik (`maxSurge`, `maxUnavailable`).
  * **Canary Deployment:** Skierowanie ułamka ruchu do nowej wersji aplikacji poprzez manipulację etykietami (`track: canary`/`stable`).

### [Laboratorium 12: Kontenery w chmurze (Azure Container Instances)](../Sprawozdanie12)
* Przygotowano lekki obraz aplikacji w oparciu o Nginx i opublikowano go w publicznym rejestrze Docker Hub.
* Użyto narzędzia Azure CLI do uwierzytelnienia oraz zdefiniowania zewnętrznej grupy zasobów.
* Pomyślnie wdrożono kontener do chmury publicznej Azure Container Instances.
* Zweryfikowano działanie aplikacji pod wygenerowanym adresem FQDN oraz pobrano logi ruchu HTTP.
* Wykonano procedurę bezpiecznego czyszczenia infrastruktury (`az group delete`) w celu zminimalizowania kosztów środowiska testowego.

---
