# Sprawozdanie 7: Automatyzacja Pipeline
**Autor:** Filip Pyrek
**Indeks:** 422032

## 1. Konfiguracja SCM i przygotowanie środowiska
Całą logikę budowania przeniosłem do pliku `Jenkinsfile`. Zrezygnowałem z przechowywania kodu aplikacji w repozytorium infrastruktury – jest on pobierany dynamicznie w etapie `Clean & Setup`. Dzięki `deleteDir()` zapewniłem czysty start każdego buildu.

![Wizualizacja etapów potoku w Blue Ocean](images/EtapyBudowania.png)

![Logi czyszczenia katalogu i klonowania zewnętrznego repozytorium](images/WyczyszczeniePoprzednichPlikow.png)

## 2. Ścieżka krytyczna: Build i Testy
Wykorzystałem Multi-stage build w Dockerze. Etap `Build (BLDR)` tworzy obraz budujący, a etap `Test` uruchamia testy jednostkowe Mocha. Potwierdzono przejście 30 testów. Sukces tego etapu jest warunkiem koniecznym do dalszego tworzenia artefaktu.

![Wynik testów i tabela Coverage](images/TestyPrzedDeploy.png)

## 3. Wdrażanie i Smoke Test (Definition of Done)
Po testach budowany jest obraz produkcyjny (`slim`). Poprawność wdrożenia weryfikuje `Smoke Test`, który za pomocą komendy `curl` sprawdza, czy kontener serwuje stronę HTML kalkulatora. Uzyskanie tytułu strony potwierdza, że artefakt jest "deployable".

![Weryfikacja działania aplikacji przez curl](images/SmokeTest2.png)

## 4. Publikacja artefaktów
Zapewniłem powtarzalność potoku poprzez automatyczne usuwanie starych kontenerów (`docker rm -f`). Potwierdzają to trzy pomyślne buildy z rzędu. Pliki `Dockerfile` i `Jenkinsfile` zostały opublikowane jako artefakty zadania, co pozwala na odtworzenie infrastruktury w innym środowisku.

![Historia pomyślnych budowań](images/WielokrotneBudowanie.png)

![Opublikowane artefakty w Jenkinsie](images/GotoweArtefakty2.png)

## Informacja o użyciu AI

1. **Ręczne zarządzanie SCM w Pipeline**:
   - **Zapytanie**: "Jak w Jenkinsie wyłączyć automatyczne pobieranie repozytorium na starcie, aby najpierw wyczyścić folder, a potem ręcznie sklonować dwa różne repozytoria (moją infrastrukturę i kod aplikacji)?"
   - **Weryfikacja**: AI wskazało na konieczność użycia opcji `options { skipDefaultCheckout(true) }`. Wyjaśniło, że bez tego Jenkins klonuje pliki przed etapem czyszczenia, co powodowałoby błędy. Po wdrożeniu tej opcji i dodaniu ręcznego `checkout scm` oraz `git clone`, potok działa poprawnie i przewidywalnie.