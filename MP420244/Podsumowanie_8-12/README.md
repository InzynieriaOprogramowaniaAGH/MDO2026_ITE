# Ansible

Ansible jest oprogramowaniem do automatyzacji procesu wdrażania oprogramowania na zdalnych urządzeniach przez protokół SSH za pomocą czytelnego pliku YAML.

## Inventory file

Plik inventory określa wszystkie węzły sieciowe, biorące udział w procesie wdrażania.

Składnia pliku:
``` ini
[<nazwa_grupy>]
<alias> ansible_host=<adres> ansible_port=<numer_portu> ansible_user=<nazwa_użytkownika> ansible_ssh_private_key_file=<ścieżka_do_klucza_SSH>
```

Program będzie mieć dostęp do wszystkich urządzeń, zdefiniowanych w pliku inventory, pod postacią skonfigurowanych aliasów.

Do utworzonych grup można odwołać się poleceniem ping programu Ansible: `ansible <grupy> -i <ścieżka_do_pliku_inventory> -m ping`. Zwraca ono stan maszyny i sukces operacji.

Przykładowa wiadomość zwrotna:
```
<alias> | SUCCESS => {
    "changed": false,
    "ping": pong
}
```

## Playbook YAML

Playbook jest plikiem, zawierającym listę instrukcji do wykonania przez Ansible na zdalnym urządzeniu. Każdy z tych plików zawiera co najmniej jeden *Play*, będący zestawem instrukcji *Task*, wykonujących operacje za pomocą modułów.

Składnia pliku:
``` yaml
- name: my_play
  hosts: all

  tasks:
  - name: my_task
    some_module:
      option: value
```

Playbook jest w stanie wykonać szeroki wachlarz operacji, w tym:
* Pobieranie i wysyłanie plików;
* Instalowanie pakietów i modułów;
* Uruchamianie serwisów;
* Zarządzanie systemem zdalnego urządzenia.

## Role

Role są nadrzędnym elementem struktury konfiguracji Ansible. Umożliwiają podział obowiązków między kilka plików konfiguracyjnych, zwiększając czytelność skryptu.

Przykładowa struktura folderów roli:
```
roles/
    common/
        tasks/
        files/
        vars/
        defaults/
        meta/
```

* `common`: folder jednej roli;
* `tasks`: lista poleceń, jak w pliku playbook;
* `files`: folder z dodatkowymi plikami;
* `vars`: zmienne roli;
* `defaults`: zmienne roli o mniejszym priorytecie;
* `meta`: metadane.

Wywołanie roli odbywa się poprzez umieszczenie w jednym z *Play*-ów playbook-a pola `roles` z nazwą roli:
``` yaml
roles:
  - common
```

# Wdrożenie nienadzorowane

Wdrożenie nienadzorowane oznacza automatyczną konfigurację środowiska bez ingerencji użytkownika. W taki sposób można stawiać nowe maszyny wirtualne i wykonywać na nich operacje przy pomocy skryptu. Do wykonania nienadzorowanego wdrożenia potrzebny jest tzw. plik odpowiedzi.

## Kickstart file

Plik odpowiedzi zawiera całą konfigurację i zestaw instrukcji, potrzebne do zbudowania, uruchomienia i przygotowania systemu do wymaganego działania.

Kickstart zawiera m.in. pola:
* `url`: link do obrazu systemu;
* `rootpw`: hasło administratora;
* `user`: dane nowego użytkownika;
* `%packages`: pakiety oprogramowania do zainstalowania;
* `%post`: skrypt do wykonania po postawieniu działającego systemu.

Za pomocą skryptu w polu `%post` można zaprogramować system do samodzielnego uruchomienia testowanej aplikacji, zapisania logów i sporządzenia raportu.

# Kubernetes

Kubernetes jest programem do zarządzania kontenerami Dockera na dużą skalę. Stanowi on otoczkę podstawowych kontenerów, zapewniając stały dostęp do serwisów, automatyczne odnawianie zepsutych węzłów, łatwą skalowalność w górę i w dół, sprawne zarządzanie architekturą kontenerów, i wiele innych.

## Komponenty

Kubernetes udostępnia szereg wbudowanych narzędzi i komponentów do zarządzania kontenerami. Każde z nich pełni osobną funkcję.

*(poniżej wybrane)*

### Klaster

Klaster jest zbiorem wszystkich komponentów niezbędnych do działania struktury.

### Pod

Pod jest najmniejszą jednostką Kubernetesa. Jest on grupą jednego lub wielu kontenerów, dzielących między sobą pamięć i zasoby sieciowe. Symuluje on pojedynczy endpoint, tj. komputer lub serwer.

### Serwis

Serwis jest abstrakcyjnym narzędziem do udostępniania podów w sieci. Ustala udostępniane porty, umożliwiając komunikację.

### Wdrożenie

Wdrożenie zawiera konfigurację podów w węźle. Określa sposób ich tworzenia, ich zawartość, ilość replik, itp. Za jego pomocą użytkownik buduje strukturę swojego programu.

### Sekret

Sekret służy do przechowywania zmiennych środowiskowych i wrażliwych danych tj. hasła, klucze, itp. Należy jednak samodzielnie zadbać o szyfrowanie danych.

### Wolumin

Wolumin służy do przechowywania danych na maszynie hostującej Kubernetes, w celu ich zachowania między sesjami. Idealne dla logów i baz danych.

### Przestrzeń nazw

Przestrzeń nazw grupuje w sobie komponenty dla mniejszego chaosu w strukturze.

## Zarządzanie programem

Lista wybranych komend:
* `kubectl apply -f <plik.yaml>`: zastosowanie wdrożenia w pliku YAML;
* `kubectl get <komponent> -n <przestrzeń nazw>`: wypisanie listy podanych komponentów w określonej przestrzeni nazw. Przykład: `kubectl get pods -n mynamespace`;
* `kubectl logs <nazwa poda>`: wypisuje logi wybranego poda. Dodanie flagi `--previous` wypisuje log przedostatniego poda;
* `kubectl rollout status deployment/<nazwa wdrożenia>`: wypisuje sukces zastosowania podanego wdrożenia;
* `minikube ip`: zwraca adres klastra;
* `minikube dashboard`: otwiera stronę w przeglądarcę z panelem kontrolnym skonfigurowanej struktury;

## Strategie wdrażania

Strategie wdrażania dotyczą sposobów wprowadzania nowego oprogramowania do produkcji.

Wyróżnia się:

### Recreate

Najprostsze do zaimplementowania, polega na wymianie wszystkich działających podów na nowe. Jest szybkie i łatwe, jednak wiąże się z tymczasową przerwą w dostawie usług.

### Rolling update

Zakłada stopniową wymianę replik starych podów na nowe, zapewniając ciągłość funkcjonalności systemu.

### Canary Deployment

Polega na dodaniu do klastra nowych podów, które będą działać równolegle ze starymi, celem przetestowania ich działania. Jest pojedynczym krokiem, który można łatwo cofnąć w razie nieporządanego działania.

# Azure

Microsoft Azure jest serwisem chmurowym do przetwarzania danych i testowania oprogramowania. Udostępniając port HTTP utworzonego kontenera, możliwe jest przeprowadzenie realistycznej symulacji operowania testowanej aplikacji w sieci.

## Obsługa oprogramowania

Tworzenie kontenerów i zarządzanie nimi jest możliwe w zintegrowanym terminalu **Cloud Shell**.

Lista podstawowych komend:
* `az group create`: tworzenie grupy zasobów;
* `az container create`: tworzenie kontenera;
* `az container show`: lista kontenerów;
* `az container logs`: logi kontenera;
* `az container delete`: usuwanie kontenera;
* `az group delete`: usuwanie grupy zasobów.

Stworzony kontener może posiadać swoje FQDN *(Fully Qualified Domain Name)* co oznacza, że dowolna osoba w sieci ma do niego dostęp. Jest to idealny sposób na hostowanie tymczasowych stron i testowanie ich działania.

Pełną nazwę domeny kontenera można sprawdzić poleceniem: `az container show --resource-group <nazwa grupy> --name <nazwa kontenera> --query ipAddress.fqdn --output tsv`.