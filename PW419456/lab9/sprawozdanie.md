# Sprawozdanie - Laboratorium 9
**Piotr Walczak 419456**

## 1. Cel zadania
Głównym celem ćwiczenia było przygotowanie źródła instalacji nienadzorowanej (opartej na pliku *Kickstart*) dla systemu operacyjnego, który zaraz po instalacji automatycznie zacznie hostować kontener wdrożony i opublikowany w ramach poprzednich laboratoriów (artefakt `piti83/libsodium-runtime:latest`). Wykorzystano sieciowy instalator systemu Fedora 44.

## 2. Konfiguracja pliku odpowiedzi (Kickstart)
Przygotowano skrypt `fedora-ks.cfg`, w którym zdefiniowano całą konfigurację wymaganą do zainstalowania oprogramowania bez interwencji użytkownika:
* Skonfigurowano repozytoria sieciowe dla Fedory 44 (dyrektywy `url` oraz `repo`).
* Zautomatyzowano proces partycjonowania, wymuszając czyszczenie całego dysku (`clearpart --all --initlabel` oraz `autopart --type=lvm`).
* Nadano niestandardową nazwę hosta: `fedora-pw419456-auto`.
* Zdefiniowano domyślnego użytkownika z uprawnieniami administratora (`ansible`).
* Zlecono instalację niezbędnych narzędzi z uwzględnieniem silnika kontenerów w sekcji `%packages` (pakiet `moby-engine`).
* Dodano dyrektywę `reboot`, gwarantującą bezobsługowe ponowne uruchomienie maszyny po zakończeniu instalacji.

Plik został udostępniony w sieci lokalnej przy pomocy wbudowanego modułu Pythona (`python3 -m http.server 8000`), co pozwoliło na bezproblemowe dostarczenie go do instalatora wewnątrz maszyny wirtualnej.

![](sprawozdanie-ss/l9_1.png)

## 3. Inicjalizacja instalacji w środowisku Hyper-V
W środowisku wirtualizacyjnym utworzono nową maszynę (Generacja 2) i wyłączono zabezpieczenie *Secure Boot*. Podczas uruchamiania instalatora przerwano sekwencję startową programu rozruchowego GRUB. 

Edytowano parametry startowe jądra systemu, dopisując na końcu linii komendę wskazującą na udostępniony plik z odpowiedziami: `inst.ks=http://172.22.171.180:8000/fedora-ks.cfg`. Od tego momentu cały proces formatowania, pobierania i konfiguracji systemu przebiegał całkowicie nienadzorowanie.

![](sprawozdanie-ss/l9_2.png)

## 4. Automatyzacja Poinstalacyjna (Sekcja %post)
Aby system od razu po instalacji hostował przygotowany wcześniej kontener aplikacji, wykorzystano sekcję `%post` w pliku Kickstart.
Wykonano tam następujące kroki:
1. Aktywowano usługę demona Docker (`systemctl enable docker.service`).
2. Wygenerowano w locie definicję nowej systemowej usługi `libsodium-app.service`.
3. W bloku `[Service]` nowej usługi wpisano instrukcję pobrania (`docker pull`) oraz uruchomienia w tle (`docker run -d`) kontenera `piti83/libsodium-runtime:latest`.
4. Zakolejkowano włączenie tej usługi, aby startowała natychmiast po załadowaniu Dockera (`systemctl enable libsodium-app.service`).

## 5. Weryfikacja działania obrazu
Po samoczynnym restarcie maszyny zalogowano się przez wygenerowane konto `ansible`. Pomyślnie zweryfikowano nową nazwę hosta maszyny (wynik komendy `hostname` to `fedora-pw419456-auto`).

![](sprawozdanie-ss/l9_3.png)

Następnie sprawdzono stan usługi kontenerowej za pomocą `sudo systemctl status docker`, upewniając się, że demon pracuje stabilnie od momentu uruchomienia jądra.

![](sprawozdanie-ss/l9_4.png)

Ostatecznym dowodem na sukces instalacji nienadzorowanej było wykonanie komendy `sudo docker ps`. Wykazała ona, że wygenerowana w procesie post-instalacyjnym usługa prawidłowo pobrała nasz autorski artefakt i uruchomiła kontener `libsodium-app` z procesem usypiającym (`sleep infinity`), co domyka cały cykl wdrożenia Continuous Deployment.

![](sprawozdanie-ss/l9_5.png)