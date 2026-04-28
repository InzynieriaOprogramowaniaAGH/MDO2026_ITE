# Sprawozdanie – Lab 8  

**Kacper Szlachta 422031**

---

## 1. Cel ćwiczenia

Celem ćwiczenia było zapoznanie się z narzędziem *Ansible* do automatyzacji zarządzania systemami oraz przygotowanie środowiska umożliwiającego zdalne wykonywanie zadań administracyjnych. W ramach zajęć wykonano inwentaryzację hostów, przygotowano playbooki, przetestowano scenariusze awarii oraz wdrożono aplikację w kontenerze *Docker* z wykorzystaniem mechanizmu *roles*.

---

## 2. Realizacja

### 2.1. Konfiguracja środowiska

Utworzono dwie maszyny wirtualne: główną (*orchestrator*) oraz docelową (*endpoint*). Na maszynie docelowej ustawiono hostname `ansible-target` oraz utworzono użytkownika `ansible`. Na maszynie głównej zainstalowano *Ansible*.

Skonfigurowano dostęp SSH bez hasła pomiędzy maszynami przy użyciu kluczy, co umożliwiło automatyczne wykonywanie poleceń.

---

### 2.2. Inwentaryzacja hostów

Utworzono plik `inventory.ini`, w którym zdefiniowano grupy hostów oraz parametry połączenia.

![Inventory](ss/inventory.png)

Zweryfikowano poprawność konfiguracji poprzez wysłanie polecenia ping do wszystkich maszyn.

![Ping SUCCESS](ss/success.png)

---

### 2.3. Playbooki

#### Ping hostów

Przygotowano playbook umożliwiający sprawdzenie dostępności wszystkich maszyn.

![Ping playbook](ss/cat_ping.png)  
![Ping result](ss/success.png)

---

#### Kopiowanie pliku inwentaryzacji

Zrealizowano kopiowanie pliku `inventory.ini` na maszynę docelową. Ponowne wykonanie operacji nie wprowadziło zmian (*changed=0*), co potwierdza idempotentność.

![Copy playbook](ss/cat_copy.png)  
![Copy result](ss/copy_inventory.png)  
![Copy repeat](ss/copy2.png)

---

#### Instalacja pakietów

Zainstalowano pakiety `nginx` oraz `rng-tools` na maszynie docelowej.

![Install playbook](ss/cat_install.png)  
![Install result](ss/install.png)

---

#### Restart usług

Zrestartowano usługi systemowe, w tym serwer SSH oraz generator liczb losowych.

![Services playbook](ss/cat_services.png)  
![Services result](ss/services.png)

---

### 2.4. Test awarii

Przeprowadzono symulację awarii poprzez wyłączenie usługi SSH na maszynie docelowej. W wyniku tego komunikacja została przerwana, a Ansible zwrócił błąd *UNREACHABLE*.

![Unreachable](ss/unreachable.png)

Po przywróceniu usługi SSH komunikacja została wznowiona.

![Recovered](ss/success.png)

---

### 2.5. Zarządzanie artefaktem – Docker

#### Instalacja Dockera

Na maszynie docelowej zainstalowano środowisko *Docker* przy użyciu Ansible.

![Docker install](ss/docker.png)

---

#### Sanity check

Przed wdrożeniem sprawdzono stan usługi Docker, co pozwoliło upewnić się, że środowisko jest poprawnie przygotowane.

![Sanity](ss/sanity.png)

---

#### Uruchomienie kontenera

Uruchomiono kontener z serwerem *nginx*. Poprawność działania została zweryfikowana poprzez zapytanie HTTP.

![Deploy](ss/deploy.png)  
![Curl](ss/curl.png)

---

#### Usunięcie kontenera

Po zakończeniu testów kontener został zatrzymany i usunięty.

![Cleanup](ss/cleanup.png)

---

### 2.6. Roles

Utworzono rolę przy użyciu narzędzia *ansible-galaxy*, a następnie zdefiniowano w niej zadania związane z instalacją Dockera oraz uruchomieniem kontenera.

![Role tasks](ss/cat_rolemain.png)

Uruchomienie roli zakończyło się powodzeniem.

![Role run](ss/role.png)

---

## 3. Podsumowanie

W ramach ćwiczenia skonfigurowano środowisko zarządzane przez *Ansible* oraz przygotowano zestaw playbooków umożliwiających automatyzację zadań administracyjnych. Wykonano inwentaryzację hostów, instalację pakietów, zarządzanie usługami oraz wdrożenie aplikacji w kontenerze *Docker*. Test awarii potwierdził poprawność działania systemu w przypadku niedostępności hosta. Zastosowanie mechanizmu *roles* umożliwiło uporządkowanie konfiguracji oraz zwiększenie jej modularności i czytelnościv