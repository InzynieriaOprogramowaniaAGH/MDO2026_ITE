# Sprawozdanie 04 - Woluminy, sieci, SSHD i Jenkins

**Jan Wojsznis 422049**

---

## 1. Zachowywanie stanu między kontenerami

W pierwszej części zadania wykorzystano woluminy Dockera do zachowania stanu między kolejnymi uruchomieniami kontenerów. Zgodnie z treścią zadania przygotowano osobny wolumin wejściowy oraz wyjściowy. Następnie uruchomiono kontener bazowy, który potrafił budować wcześniej wybrany projekt, i podłączono do niego oba woluminy. :contentReference[oaicite:1]{index=1}

![Obraz bazowy użyty do budowania projektu](./ss/4/04-base-image.png)

Na początku utworzono woluminy `lab04-input` oraz `lab04-output`, które miały przechowywać odpowiednio kod źródłowy oraz wynik procesu budowania. Repozytorium projektu zostało sklonowane na wolumin wejściowy, a następnie wykonano build wewnątrz kontenera bazowego. Wynik budowania zapisano na woluminie wyjściowym. Po zakończeniu pracy sprawdzono, że pliki nadal były dostępne po wyjściu z kontenera, co potwierdziło zachowanie stanu między kolejnymi uruchomieniami. W drugim wariancie zadania powtórzono operację, ale klonowanie repozytorium wykonano już bezpośrednio z poziomu kontenera. :contentReference[oaicite:2]{index=2}

![Utworzenie woluminów](./ss/4/04-volumes-created.png)

![Uruchomienie kontenera bazowego z podpiętymi woluminami](./ss/4/04-build-container-start.png)

![Wynik builda zapisany na woluminie wyjściowym](./ss/4/04-build-output-volume.png)

![Drugi wariant builda z klonowaniem w kontenerze](./ss/4/04-volume-build-b.png)

![Repozytorium sklonowane na wolumin](./ss/4/04-volume-clone.png)

![Sprawdzenie zachowania danych po wyjściu z kontenera](./ss/4/04-output-persisted.png)

---

## 2. Porty i komunikacja między kontenerami

W drugiej części zadania uruchomiono kontenery z wykorzystaniem narzędzia `iperf3`, aby sprawdzić komunikację sieciową między nimi. Najpierw serwer `iperf3` został uruchomiony w domyślnej sieci Dockera, a klient połączył się z nim po adresie IP odczytanym z konfiguracji kontenera. Następnie wykonano analogiczny test w utworzonej własnej sieci mostkowej, tym razem wykorzystując nazwę kontenera zamiast ręcznego podawania adresu IP. :contentReference[oaicite:3]{index=3}

![Połączenie przez domyślną sieć Dockera](./ss/4/04-iperf-default-network.png)

![Połączenie przez własną sieć mostkową](./ss/4/04-iperf-custom-network.png)

W dalszym kroku wystawiono port serwera `iperf3` na hosta i sprawdzono możliwość połączenia z poziomu systemu gospodarza. Dzięki temu zweryfikowano zarówno komunikację między kontenerami, jak i sposób udostępniania usług kontenera na zewnątrz. :contentReference[oaicite:4]{index=4}

![Dostęp do usługi z hosta](./ss/4/04-iperf-host-access.png)

---

## 3. SSHD w kontenerze

Kolejny etap polegał na uruchomieniu w kontenerze systemowym usługi `SSHD`. W tym celu uruchomiono kontener z obrazu `ubuntu`, doinstalowano pakiet `openssh-server`, przygotowano katalog `/run/sshd`, ustawiono hasło użytkownika `root` i uruchomiono demona `sshd`. Następnie z poziomu hosta wykonano połączenie przez `ssh` na wystawiony port kontenera. 

![Uruchomienie SSHD w kontenerze](./ss/4/04-sshd-container.png)

![Logowanie do kontenera przez SSH](./ss/4/04-sshd-login.png)

Takie podejście ma zaletę w postaci możliwości zdalnego wejścia do kontenera przy użyciu standardowych narzędzi administracyjnych. Wadą jest jednak to, że kontener zaczyna pełnić rolę bardziej zbliżoną do klasycznej maszyny systemowej, co nie zawsze jest zgodne z lekkim i jednoużytkowym modelem pracy kontenerów.

---

## 4. Jenkins i Docker-in-Docker

W ostatniej części zadania uruchomiono środowisko złożone z `Docker-in-Docker` oraz `Jenkins`. Najpierw utworzono dedykowaną sieć, a następnie uruchomiono kontener `jenkins-dind` w trybie uprzywilejowanym. Po tym uruchomiono kontener `jenkins`, który został podłączony do tej samej sieci i skonfigurowany tak, aby komunikował się z usługą Dockera działającą w kontenerze DIND. :contentReference[oaicite:6]{index=6}

![Uruchomienie Docker-in-Docker](./ss/4/04-jenkins-dind-run.png)

![Uruchomienie kontenera Jenkins](./ss/4/04-jenkins-run.png)

Po uruchomieniu środowiska pobrano hasło startowe Jenkinsa, otwarto interfejs WWW i zalogowano się do panelu. W ten sposób potwierdzono poprawne działanie kontenera Jenkins oraz jego dostępność z poziomu przeglądarki.

![Panel logowania / interfejs Jenkins](./ss/4/04-jenkins-ui.png)

![Interfejs Jenkins po uruchomieniu](./ss/4/04-jenkins-ui2.png)