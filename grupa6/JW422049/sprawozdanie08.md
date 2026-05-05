# Sprawozdanie 08 - Ansible

**Jan Wojsznis 422049**

---

## 1. Inventory i połączenie z maszynami

W ramach zajęć przygotowano środowisko Ansible składające się z maszyny głównej `devops` oraz maszyny docelowej `ansible-target`. Na maszynie głównej utworzono plik `inventory.ini`, w którym zdefiniowano dwie grupy: `Orchestrators` oraz `Endpoints`.

Maszyna `devops` została skonfigurowana jako lokalny orchestrator, natomiast `ansible-target` jako endpoint zarządzany przez SSH. Po przygotowaniu inventory wykonano test połączenia za pomocą modułu `ping`. Obie maszyny odpowiedziały poprawnie statusem `SUCCESS`.

![Inventory i ping Ansible](./ss/8/01-inventory-ping.png)

---

## 2. Pierwszy playbook ping

Następnie przygotowano prosty playbook `ping.yml`, którego zadaniem było sprawdzenie dostępności wszystkich hostów zdefiniowanych w inventory. Playbook korzystał z modułu `ansible.builtin.ping`.

Po uruchomieniu playbooka oba hosty, czyli `devops` oraz `ansible-target`, zakończyły zadanie poprawnie. Potwierdziło to, że inventory działa prawidłowo, a Ansible może wykonywać zadania zarówno lokalnie, jak i na maszynie docelowej.

![Playbook ping](./ss/8/02-playbook-ping.png)

---

## 3. Kopiowanie pliku inventory

W kolejnym kroku przygotowano playbook `copy-inventory.yml`, który kopiował plik `inventory.ini` na maszynę docelową do katalogu domowego użytkownika `ansible`.

Playbook został uruchomiony dwa razy. Przy pierwszym uruchomieniu plik został skopiowany, dlatego Ansible zwrócił `changed=1`. Przy drugim uruchomieniu plik był już obecny i nie wymagał zmian, dlatego wynik zmienił się na `changed=0`. Pokazuje to idempotentne działanie modułu `copy`.

![Kopiowanie inventory](./ss/8/03-copy-inventory.png)

---

## 4. Aktualizacja pakietów i restart usług

Następnie wykonano playbook `update-services.yml`, który aktualizował cache pakietów, wykonywał upgrade pakietów oraz restartował wybrane usługi na maszynie `ansible-target`.

Restart usługi `ssh` zakończył się poprawnie. Próba restartu `rng-tools` zwróciła komunikat, że taka usługa nie istnieje na maszynie docelowej. Błąd ten został jednak zignorowany przez `ignore_errors`, dlatego cały playbook zakończył się poprawnie i w podsumowaniu widoczny był wynik `failed=0`.

![Aktualizacja pakietów i restart usług](./ss/8/04-update-services.png)

---

## 5. Test niedostępności hosta

W celu sprawdzenia reakcji Ansible na niedostępny host zatrzymano usługę SSH na maszynie `ansible-target`. Następnie ponownie wykonano test połączenia za pomocą Ansible.

Maszyna lokalna `devops` odpowiedziała poprawnie statusem `SUCCESS`, natomiast `ansible-target` został oznaczony jako `UNREACHABLE`. W komunikacie pojawiła się informacja o odmowie połączenia na porcie 22. Potwierdziło to, że Ansible poprawnie wykrywa brak dostępności hosta zarządzanego.

![Host niedostępny po wyłączeniu SSH](./ss/8/05-unreachable-ssh-off.png)

Po ponownym uruchomieniu usługi SSH na maszynie docelowej wykonano kolejny test połączenia. Tym razem oba hosty odpowiedziały poprawnie, co potwierdziło przywrócenie komunikacji z endpointem.

![Przywrócenie połączenia SSH](./ss/8/06-recovered-ssh.png)

---

## 6. Instalacja Dockera przez Ansible

W następnym etapie przygotowano playbook `install-docker.yml`, którego zadaniem była instalacja Dockera na maszynie docelowej. Playbook instalował pakiet `docker.io`, uruchamiał usługę Docker, dodawał użytkownika `ansible` do grupy `docker` oraz sprawdzał wersję zainstalowanego Dockera.

Po wykonaniu playbooka Docker był dostępny na maszynie `ansible-target`, a wynik polecenia `docker --version` potwierdził poprawną instalację.

![Instalacja Dockera](./ss/8/07-install-docker.png)

---

## 7. Wdrożenie kontenera nginx

Po zainstalowaniu Dockera przygotowano playbook `deploy-nginx.yml`, który pobierał obraz `nginx:stable-alpine`, usuwał ewentualny stary kontener oraz uruchamiał nowy kontener `lab8-nginx`.

Kontener został uruchomiony na maszynie `ansible-target`, a port `80` kontenera został wystawiony na porcie `8081` hosta. W wyniku `docker ps` widoczny był działający kontener `lab8-nginx`.

![Deploy kontenera nginx](./ss/8/08-deploy-nginx.png)

Poprawność działania kontenera została sprawdzona z maszyny głównej za pomocą polecenia `curl`. Odpowiedź zawierała stronę powitalną nginx, co potwierdziło, że wdrożona usługa działa poprawnie.

![Sprawdzenie nginx przez curl](./ss/8/09-curl-nginx.png)

---

## 8. Cleanup kontenera

Po sprawdzeniu działania usługi wykonano playbook `cleanup-nginx.yml`, którego zadaniem było usunięcie kontenera `lab8-nginx`. Po usunięciu kontenera wykonano sprawdzenie listy kontenerów za pomocą `docker ps -a --filter name=lab8-nginx`.

W wyniku widoczny był jedynie nagłówek tabeli, co oznaczało, że kontener został poprawnie usunięty.

![Cleanup kontenera nginx](./ss/8/10-cleanup-nginx.png)

---

## 9. Rola Ansible

W ostatniej części przygotowano rolę Ansible `nginx_container`. Rola realizowała podobne zadania jak wcześniejszy playbook deployujący nginx: sprawdzała Dockera, pobierała obraz nginx, usuwała poprzedni kontener i uruchamiała nowy kontener `lab8-role-nginx`.

Do uruchomienia roli przygotowano playbook `role-nginx.yml`. Po jego wykonaniu kontener `lab8-role-nginx` został uruchomiony na maszynie docelowej i wystawiony na porcie `8082`.

![Deploy nginx przez rolę](./ss/8/11-role-nginx.png)

Działanie kontenera uruchomionego przez rolę sprawdzono poleceniem `curl`. Odpowiedź zawierała stronę powitalną nginx, co potwierdziło poprawne działanie roli.

![Sprawdzenie nginx z roli](./ss/8/12-curl-role-nginx.png)

---

## 10. Podsumowanie

W ramach zajęć 08 przygotowano środowisko Ansible złożone z maszyny głównej `devops` oraz maszyny docelowej `ansible-target`. Skonfigurowano inventory, połączenie SSH oraz wykonano podstawowe testy dostępności hostów.

Następnie przygotowano i uruchomiono playbooki odpowiedzialne za kopiowanie plików, aktualizację systemu, restart usług, wykrywanie niedostępnego hosta, instalację Dockera, wdrożenie kontenera nginx oraz cleanup. Na końcu utworzono rolę Ansible, która również wdrażała kontener nginx, tym razem w bardziej uporządkowanej strukturze.

Całość potwierdziła, że Ansible może zarządzać maszyną docelową, wykonywać zadania administracyjne, instalować usługi oraz uruchamiać kontenery Docker.