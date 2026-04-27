# Sprawozdanie podsumowujące - Jenkins, pipeline i automatyzacja CI/CD

**Jan Wojsznis 422049**

---

## 1. Przygotowanie środowiska Jenkins

W pierwszym etapie przygotowano środowisko Jenkins działające w kontenerach Dockera. Na początku sprawdzono lokalne obrazy i kontenery pozostałe po poprzednich zajęciach. Potwierdzono obecność obrazów `lab03-build` i `lab03-test`, które były potrzebne jako wcześniejsze kontenery budujące i testujące. Następnie usunięto stare kontenery związane z Jenkinsem i przygotowano nową sieć Dockera przeznaczoną dla środowiska CI.

![Stan początkowy kontenerów i obrazów](./ss/5/05-start-state.png)

W kolejnym kroku uruchomiono kontener `jenkins-dind`, czyli środowisko Docker-in-Docker, które pozwala Jenkinsowi korzystać z Dockera podczas wykonywania zadań.

![Uruchomienie Docker-in-Docker](./ss/5/05-dind-run.png)

Następnie przygotowano i uruchomiono kontener Jenkins z wtyczkami Blue Ocean oraz Docker Workflow. Kontener został podłączony do tej samej sieci co `jenkins-dind`, a zmienna `DOCKER_HOST` została ustawiona tak, aby Jenkins komunikował się z usługą Dockera działającą w kontenerze DIND.

![Uruchomienie Blue Ocean / Jenkins](./ss/5/05-blueocean-run.png)

Po uruchomieniu kontenera pobrano hasło startowe Jenkinsa, zalogowano się do interfejsu WWW i wykonano podstawową konfigurację, w tym instalację sugerowanych wtyczek oraz utworzenie konta administratora.

![Logowanie do Jenkinsa](./ss/5/05-jenkins-login.png)

![Panel główny Jenkinsa](./ss/5/05-jenkins-dashboard.png)

---

## 2. Zadania wstępne w Jenkinsie

Po uruchomieniu środowiska przygotowano kilka prostych zadań typu freestyle. Pierwszy projekt wyświetlał informacje o systemie za pomocą polecenia `uname -a`. Pozwoliło to sprawdzić, że Jenkins poprawnie wykonuje polecenia powłoki.

![Projekt uname](./ss/5/05-job-uname.png)

Następnie utworzono drugi projekt, który zwracał błąd w sytuacji, gdy aktualna godzina była nieparzysta. W zadaniu wykorzystano polecenie `date +%H` i prosty warunek sprawdzający parzystość godziny. Dzięki temu uzyskano przykład zadania, które może zakończyć się sukcesem albo błędem zależnie od czasu uruchomienia.

![Projekt sprawdzający parzystość godziny](./ss/5/05-job-odd-hour.png)

W trzecim projekcie wykonano polecenie `docker pull ubuntu`, aby sprawdzić możliwość pobierania obrazów Dockera bezpośrednio z poziomu zadania uruchamianego przez Jenkins.

![Projekt docker pull ubuntu](./ss/5/05-job-docker-pull.png)

---

## 3. Pierwszy obiekt typu pipeline

W dalszej części utworzono nowy obiekt typu `pipeline`. Treść pipeline’u została wpisana bezpośrednio do obiektu w Jenkinsie, bez korzystania z SCM. Pipeline składał się z podstawowych etapów:
- klonowanie repozytorium przedmiotowego `MDO2026_ITE`,
- przejście na osobistą gałąź `JW422049`,
- budowanie pliku `Dockerfile` właściwego dla buildera używanego we wcześniejszych zadaniach.

![Konfiguracja pipeline](./ss/5/05-pipeline-config.png)

Podczas pierwszego uruchomienia pipeline wykonał próbę klonowania repozytorium, przejścia do odpowiedniej gałęzi oraz budowania obrazu Dockera. Pozwoliło to sprawdzić podstawową logikę działania pipeline’u i sposób wykonywania etapów wewnątrz Jenkinsa.

![Pierwsze uruchomienie pipeline](./ss/5/05-pipeline-run1.png)

Zgodnie z poleceniem pipeline został następnie uruchomiony drugi raz. W drugim przebiegu pojawił się błąd wynikający z istnienia katalogu `MDO2026_ITE` w przestrzeni roboczej, co zostało pokazane w logach. Był to rzeczywisty efekt ponownego uruchomienia tego samego pipeline’u bez czyszczenia workspace, dzięki czemu udało się zaobserwować zachowanie procesu przy kolejnym przebiegu.

![Drugie uruchomienie pipeline](./ss/5/05-pipeline-run2.png)

---

## 4. Plan procesu CI/CD i diagram UML

W kolejnych zajęciach przygotowano diagram UML przedstawiający planowany proces CI/CD. Diagram obejmował kolejne etapy działania pipeline:
- manual trigger lub commit,
- clone repo,
- checkout branch,
- build Dockerfile,
- test,
- deploy,
- smoke test,
- publish artifact.

Diagram pełnił rolę planu procesu i punktu odniesienia przy dalszym rozwijaniu pipeline’u.

![](./ss/6/06-uml.png)

---

## 5. Kontener buildowy, Dockerfile i repozytorium

Do realizacji pipeline wykorzystano repozytorium przedmiotowe `MDO2026_ITE`. Prace były prowadzone na własnej gałęzi `JW422049`, co pozwoliło bezpiecznie rozwijać rozwiązanie bez ingerencji w inne gałęzie repozytorium.

Jako kontener bazowy wykorzystano przygotowany wcześniej `Dockerfile` oparty o `ubuntu:24.04`. Obraz ten pełnił rolę prostego kontenera buildera i testera. Build był wykonywany wewnątrz kontenera, a tag obrazu został określony jawnie. Sam plik `Dockerfile` został zapisany w repozytorium jako osobny plik.

![](./ss/6/05-dockerfile-repo.png)

---

## 6. Rozszerzony pipeline w Jenkinsie

Następnie zdefiniowano właściwy obiekt typu pipeline w Jenkinsie. Pipeline został uruchomiony ręcznie z poziomu interfejsu WWW. W jego działaniu zrealizowano pełną ścieżkę krytyczną:
- manual trigger,
- clone,
- build,
- test,
- deploy,
- publish.

Dzięki temu udało się przejść od prostych zadań freestyle do pełnego procesu automatyzacji.

![](./ss/6/01-pipeline-success.png)

Podczas pracy pojawiały się problemy związane z workspace i dostępnością Built-In Node, jednak po wyczyszczeniu przestrzeni roboczej i ponownym uruchomieniu środowiska pipeline działał poprawnie. Dodatkowo potwierdzono obecność pliku `Jenkinsfile` w repozytorium.

![](./ss/6/04-jenkinsfile-repo.png)

---

## 7. Realizacja etapów build, test, deploy i publish

W etapie `build` tworzony był obraz Docker na podstawie pliku `Dockerfile` z katalogu `grupa6/JW422049`. Oznacza to, że pipeline miał dostęp do wymaganych plików i potrafił zbudować odpowiedni obraz buildera.

W etapie `test` uruchamiano zbudowany obraz i sprawdzano poprawność jego działania. Test polegał na uruchomieniu obrazu i wykonaniu prostego sprawdzenia narzędzi obecnych w obrazie. Dzięki temu potwierdzono, że obraz został poprawnie zbudowany i może zostać użyty w dalszych etapach.

W etapie `deploy` uruchamiano kontener na podstawie obrazu zbudowanego wcześniej. Następnie wykonywano prosty smoke test potwierdzający, że kontener działa poprawnie. Pipeline nie kończył się więc wyłącznie na buildzie, ale przechodził również do uruchomienia przygotowanego obrazu.

![](./ss/6/02-console-success.png)

W etapie `publish` przygotowywany był artefakt w formacie `tar.gz`, którego nazwa zawierała numer builda. Dzięki temu można było łatwo określić, z którego wykonania pipeline pochodzi dany plik. Artefakt był zapisywany jako rezultat builda w Jenkinsie i dostępny do pobrania z poziomu interfejsu WWW.

![](./ss/6/03-artifact.png)

---

## 8. Jenkinsfile w repozytorium i jego weryfikacja

W dalszym etapie sprawdzono, czy przygotowany pipeline nie znajduje się wyłącznie w ustawieniach obiektu Jenkins, ale został również zapisany jako plik `Jenkinsfile` w repozytorium. Dzięki temu definicja procesu budowania stała się częścią kodu projektu i może być rozwijana razem z pozostałymi plikami.

Na screenie pokazano plik `Jenkinsfile` znajdujący się w katalogu projektu `grupa6/JW422049`. W pliku widoczne były kolejne etapy pipeline, w tym `Clone repo`, `Checkout builder Dockerfile`, `Build Dockerfile`, `Test`, `Deploy` oraz `Publish`.

![Jenkinsfile w repozytorium](./ss/7/01-jenkinsfile-repo.png)

---

## 9. Praca pipeline na świeżym kodzie

Kolejne uruchomienie pipeline zostało wykonane po uprzednim czyszczeniu katalogu roboczego. W logach potwierdzono, że przed nowym przebiegiem czyszczony był workspace, a następnie wykonywane były `git clone` oraz `git checkout` właściwej gałęzi `JW422049`. Dzięki temu pipeline pracował na aktualnym kodzie, a nie na danych pozostawionych po poprzednim uruchomieniu.

Na tym etapie widoczne było również przejście do etapu budowania obrazu Docker.

![Czyszczenie workspace, clone i checkout](./ss/7/02-clean-clone-build.png)

---

## 10. Etapy Build, Test, Deploy i Publish w Jenkinsfile

W etapie `Build` pipeline miał dostęp do repozytorium oraz pliku `Dockerfile` znajdującego się w katalogu `grupa6/JW422049`. Następnie tworzony był obraz buildowy `lab05-builder`, który stawał się podstawą dalszych kroków.

W etapie `Test` uruchamiano wcześniej zbudowany obraz i wykonywano prosty test działania, polegający na sprawdzeniu poprawności działania narzędzia `git` wewnątrz obrazu.

W etapie `Deploy` przygotowywano kontener `lab05-deploy` na podstawie obrazu `lab05-builder`. Następnie kontener był uruchamiany, sprawdzano jego obecność na liście aktywnych kontenerów oraz wykonywano wewnątrz niego polecenie testowe. Oznacza to, że etap `Deploy` zarówno przygotowywał obraz pod wdrożenie, jak i przeprowadzał samo wdrożenie w środowisku kontenerowym.

![Test oraz deploy kontenera](./ss/7/03-test-deploy.png)

W etapie `Publish` przygotowywany był artefakt w postaci archiwum `tar.gz`, a następnie dodawany do historii builda w Jenkinsie. Dzięki temu rezultat konkretnego uruchomienia pipeline mógł zostać zapisany i udostępniony do pobrania z poziomu interfejsu WWW.

![Publikacja artefaktu](./ss/7/04-publish-artifact.png)

---

## 11. Kolejne poprawne uruchomienia pipeline

Po kolejnym uruchomieniu pipeline zakończył się on statusem `SUCCESS`. Na stronie builda widoczny był numer wykonania, status sukcesu oraz opublikowany artefakt. Potwierdza to, że pipeline działa poprawnie nie tylko przy jednym przebiegu, ale również przy kolejnych uruchomieniach.

![Kolejne poprawne uruchomienie pipeline](./ss/7/05-second-run-success-1.png)

Dodatkowo sprawdzono historię uruchomień pipeline. Widok trendu czasu zadań potwierdził, że proces był wykonywany wielokrotnie, a ostatnie przebiegi kończyły się sukcesem. Dzięki temu można uznać, że przygotowany `Jenkinsfile` pokrywa wymaganą ścieżkę krytyczną i działa poprawnie w praktyce.

![Historia kolejnych uruchomień pipeline](./ss/7/05-second-run-success-2.png)

---

## 12. Podsumowanie

W ramach laboratoriów 05–07 udało się przejść od podstawowego uruchomienia środowiska Jenkins do przygotowania kompletnego pipeline’u CI/CD opartego o Docker i Jenkinsfile. Najpierw skonfigurowano środowisko Jenkins z Docker-in-Docker i Blue Ocean, następnie przygotowano proste zadania freestyle i pierwszy obiekt pipeline. W dalszej części opracowano diagram procesu CI/CD, zapisano `Dockerfile` oraz `Jenkinsfile` w repozytorium, a następnie zrealizowano pełną ścieżkę:
- clone,
- build,
- test,
- deploy,
- publish.

Ostatecznie potwierdzono, że pipeline działa poprawnie również przy kolejnych uruchomieniach, korzysta z aktualnego kodu, publikuje artefakty i stanowi działającą podstawę do dalszego rozwijania procesu automatyzacji.
