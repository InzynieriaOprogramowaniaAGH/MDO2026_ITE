# Zajęcia 08 - Automatyzacja i zdalne wykonanie za pomocą Ansible 
## Wojciech Pieńkowski

---

### Instalacja oprogramowania Ansible na maszynie sterującej (Orkiestratorze) przy użyciu menadżera pakietów apt.
![1](sprawozdanie8/1.png)

### Konfiguracja pliku inwentaryzacji host.ini, w którym zdefiniowano grupę [my_nodes] oraz parametry dostępu SSH do maszyny docelowej.
![2](sprawozdanie8/2.png)

### Skuteczna wymiana kluczy SSH za pomocą ssh-copy-id praz weryfikacja łączności ping.
![3](sprawozdanie8/3.png)

### Przygotowanie głównego playbooka setup.yml, który wykorzystuje strukture ról do zachowania czystości.
![4](sprawozdanie8/4.png)

### Implementacja zadań wewnątrz roli, obejmująca sanity check, instalacje silnika docker i uruchomienia kontenera.
![5](sprawozdanie8/5.png)

### Pomyślnie uruchomienie pełnego procesu automatyzacji.
![6](sprawozdanie8/6.png)

### Ręczna weryfikacja stanu maszyny docelowej komendą sudo docker ps, obecność dockera potwierdza poprawne uruchomienie.
![7](sprawozdanie8/7.png)

### Czyszczenie środowiska przy użyciu polecenia ad-hoc.
![8](sprawozdanie8/8.png)
