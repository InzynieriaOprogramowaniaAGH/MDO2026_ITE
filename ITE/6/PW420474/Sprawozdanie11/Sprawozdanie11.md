# L11

### Przygotowanie obrazów
* **Budowa i transfer (12-16):** Przygotowanie wersji `v3` oraz celowo wadliwego obrazu `err` opartego na `/bin/false`. Obrazy zostały załadowane do lokalnego rejestru minikube.
![12.png](12.png) ![13.png](13.png) ![14.png](14.png) ![15.png](15.png) ![16.png](16.png)

### Skalowanie i cykl życia wdrożenia
* **Zarządzanie replikami (1-2, 17-24):** Deklaratywne skalowanie deploymentu (zakres 0-6 replik) poprzez modyfikację pól `replicas` w pliku YAML.
![1.png](1.png) ![2.png](2.png) ![17.png](17.png) ![18.png](18.png) ![19.png](19.png) ![20.png](20.png) ![21.png](21.png) ![22.png](22.png) ![23.png](23.png) ![24.png](24.png)

### Weryfikacja i obsługa błędów
* **Działanie usługi (3):** Potwierdzenie poprawnej serwacji treści przez Nginx z customową konfiguracją.
![3.png](3.png)
* **Obsługa awarii (4, 25, 5):** Symulacja błędu wdrożenia (obraz `err`) skutkująca statusem `CrashLoopBackOff`, a następnie przywrócenie stabilnej wersji przez `rollout undo`.
![4.png](4.png) ![25.png](25.png) ![5.png](5.png)

### Automatyzacja i strategie
* **Healthcheck (6-7):** Skrypt bash weryfikujący status wdrożenia w zadanym oknie czasowym (60s).
![6.png](6.png) ![7.png](7.png)
* **Strategie (8-10):** Implementacja strategii `Recreate` oraz `RollingUpdate` z limitami dostępności. Na koniec wdrożenie typu `Canary` z podziałem ruchu na wersje `stable` i `canary`.
![8.png](8.png) ![9.png](9.png) ![10.png](10.png)

### Czemu serwis?

Ten serwis pozwala nam podzielić ruch pomiędzy różne pody, (balansowanie ruchu) oraz pozwala nam serwować eksperymentalne i nowe funkcjonalności bez wpływania na głowny ruch, co pozwala nam testować i eksperymentować z udziałem odbiorców naszego serwisu.
