# Sprawozdanie 8: Konfiguracja i Wdrożenie przy użyciu Ansible
**Autor:** Filip Pyrek
**Indeks:** 422032

## 1. Konfiguracja Inwentaryzacji
Pracę z Ansible rozpocząłem od zdefiniowania infrastruktury. Skonfigurowałem nazwy maszyn oraz utworzyłem plik inwentarza (`inventory.ini`), przypisując maszyny do odpowiednich grup (np. węzeł sterujący i węzły docelowe). Dzięki temu Ansible wie, z którymi hostami ma się komunikować.

![Dodanie nazw maszyn w konfiguracji](images/DodanieNazwMaszyn.png)

## 2. Połączenie SSH i konfiguracja uprawnień (Sudo)
Aby automatyzacja mogła przebiegać bez interwencji użytkownika, konieczne było zestawienie połączenia między maszynami oraz nadanie odpowiednich uprawnień. Zalogowałem się na serwer docelowy i edytowałem plik `sudoers` (za pomocą `visudo`), usuwając wymóg podawania hasła dla użytkownika wykonującego skrypty Ansible.

![Nawiązanie połączenia z serwerem docelowym](images/PolaczenieZSerwerem.png)

![Usunięcie wymogu hasła dla sudo](images/UsuniecieWymoguHaslaDlaSudoSerwera.png)

## 3. Weryfikacja łączności (Moduł Ping)
Po skonfigurowaniu kluczy SSH i uprawnień, wykonałem podstawowy test komunikacji za pomocą wbudowanego modułu `ping` (`ansible all -m ping`). Uzyskanie statusu `pong` od maszyn docelowych potwierdziło, że węzeł sterujący może poprawnie zarządzać infrastrukturą.

![Wydanie polecenia ping na wszystkie maszyny](images/PingAll.png)

![Pozytywny wynik sprawdzenia łączności z serwerami](images/SprawdzenieLacznosci.png)

## 4. Konfiguracja wstępna i zadania ad-hoc
Przed właściwym wdrożeniem wykonałem podstawowe zadania administracyjne na serwerach, takie jak synchronizacja czasu. Zapewnia to spójność logów pomiędzy różnymi maszynami w infrastrukturze.

![Synchronizacja daty i czasu na węzłach](images/SynchronizacjaDat.png)

## 5. Wdrożenie artefaktu (Rola Ansible i Docker)
Głównym zadaniem było napisanie strukturalnej Roli Ansible (`deploy_calculator`), która instaluje Dockera i wdraża aplikację webową z Docker Hub. Ze względu na błędy systemowych bibliotek Pythona (`http+docker`), zaimplementowałem odporne na błędy podejście wykorzystujące moduł `shell` z weryfikacją `changed_when`. Playbook wdrożył kontener z aplikacją i przeszedł pozytywnie zautomatyzowany test HTTP (Sanity Check), kończąc się pełnym sukcesem.

![Pomyślne wdrożenie kalkulatora na serwerze - podsumowanie Playbooka](images/WdrozenieKalkulatoraNaSerwerze.png)

---

## Informacja o użyciu AI

1. **Błąd komunikacji Ansible z Dockerem (`http+docker`)**:
   * **Zapytanie**: "Dlaczego przy próbie pobrania obrazu z Docker Huba przez moduł `community.docker` otrzymuję błąd `Not supported URL scheme http+docker` na nowej maszynie?"
   * **Weryfikacja**: AI wyjaśniło, że jest to znany konflikt bibliotek Pythona na systemie Ubuntu. Zaproponowało stworzenie obejścia przy użyciu modułu `shell` (komendy systemowe) z zachowaniem zasad idempotentności (dodanie warunków `changed_when`). Po wdrożeniu tego rozwiązania pobieranie i uruchamianie obrazu przebiegło bezbłędnie.
