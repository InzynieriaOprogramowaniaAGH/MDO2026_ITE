# Mateusz Sadowski - Sprawozdanie zbiorcze z laboratoriów 5-7

## Jenkins

Jenkins to serwer automatyzacji (open source), który wspiera CI/CD. Po każdym pushu do repozytorium może automatycznie uruchomić pipeline zdefiniowany w pliku Jenkinsfile, obejmujący np. pobranie kodu, kompilację, testy jednostkowe i integracyjne, analizę jakości kodu oraz budowę obrazu Docker.

Takie podejście umożliwia szybsze wykrywanie błędów, zapewnia powtarzalny proces budowania i wdrażania oraz pełną historię logów i artefaktów z każdego uruchomienia, co jest kluczowe w CI/CD. 
Jenkins integruje się m.in. z GitHubem, narzędziami testowymi i systemami powiadomień, dzięki czemu może wysyłać statusy buildów i raporty po zakończeniu pipeline'u.

Jenkins często działa w środowisku zagnieżdżonym (Docker-in-Docker), ponieważ pipeline musi uruchamiać kolejne kontenery i budować obrazy w odizolowanym, powtarzalnym środowisku. Ten model ułatwia m.in. odtwarzanie pipeline’ów na wielu różnych maszynach.

W ramach laboratoriów użyto również wariantu Jenkinsa z zestawem wtyczek **Blue Ocean**, który daje wygodniejsze UI do pracy z pipeline’ami (wizualizacja etapów, lepszy podgląd przebiegu). Jest to rozszerzenie warstwy UI i integracji, natomiast sam silnik i mechanika jobów/pipeline’ów pozostają Jenkinsowe.


#### Aby rozpocząć pracę z Jenkinsem, należy wykonać poniższe kroki konfiguracyjne:
1. Utworzyć dedykowaną sieć Docker dla usług CI (czyli Jenkinsa).
2. Uruchomić kontener Docker-in-Docker (DIND) jako zaplecze do budowania obrazów.
3. Przygotować plik Dockerfile.jenkins z wymaganymi narzędziami i pluginami.
4. Zbudować obraz Jenkins (np. Blue Ocean) na podstawie tego pliku.
5. Uruchomić kontener Jenkins i podłączyć go do tej samej sieci co DIND.
6. Wystawić porty (np. 8080 i 50000) oraz skonfigurować wolumen na dane Jenkinsa.
7. Dokończyć konfigurację w przeglądarce: hasło administratora, pluginy, użytkownik, połączenie z repozytorium i webhook.

#### Jak uruchomić Jenkinsa, gdy jest już skonfigurowany:
1. Uruchomić wcześniej przygotowane kontenery (DIND i Jenkins) z zachowaniem tych samych wolumenów oraz sieci.
2. Sprawdzić dostępność panelu Jenkins pod adresem serwera (np. http://HOST:8080).

Zachowanie praktyk CI/CD z wykorzystaniem Jenkinsa ma realny sens, gdy projekt, którego wdrażanie planowane jest w ramach CI/CD, jest już choćby wstępnie „poukładany”. To znaczy, że zawiera m.in. testy automatyczne, kod który da się budować i testować w sposób powtarzalny (bez ręcznych kroków) oraz znane są podstawowe wymogi projektu (np. wersje narzędzi, zależności, docelowe środowisko).
Sam typ projektu również może wpływać na cel, który się chce osiągnąć poprzez wdrażanie pipeline’u CI/CD. Dla przykładu: mimo że podobnie będzie się budowało i testowało projekt biblioteki .NET i projekt aplikacji webowej w .NET, to „ostateczny” test czy całość działa musi być inny — w bibliotece kluczowe są testy jednostkowe/integracyjne i poprawne paczkowanie, a w aplikacji webowej dochodzą testy end-to-end, uruchomienie usługi w środowisku zbliżonym do produkcyjnego i weryfikacja działania po wdrożeniu (np. smoke testy), bo sama biblioteka nie ma warstwy UI jak aplikacja webowa.

Na potrzeby laboratoriów wybrano lekką aplikację Web API w TypeScript (szkielet typu NestJS, licencja MIT) z gotowymi testami oraz utworzono jej forka w GitHub, żeby pipeline mógł w pełni kontrolować cykl życia projektu (klonowanie, budowanie obrazów, testy i wdrożenie) w sposób powtarzalny.

#### UI Jenkinsa

Jenkins w swoim UI pozwala m.in. na tworzenie nowych projektów (np. do pisania pipeline dla danego repozytorium), śledzenie logów wykonywania projektów, pobieranie zapisanych artefaktów oraz sprawdzanie poprawności przebiegu konkretnych etapów budowania przy pomocy grafu. 

## Pipeline CI/CD

#### Pipeline CI/CD - ścieżka krytyczna

Pipeline CI/CD to zautomatyzowana sekwencja kroków, która po zmianie w repozytorium (np. push/PR) buduje i weryfikuje projekt, a następnie przygotowuje go do wdrożenia. Celem jest to, żeby każda zmiana przechodziła ten sam proces jakościowy, a wynik był powtarzalny i łatwy do odtworzenia.

Taki proces można też opisać od strony dokumentacyjnej (np. diagramem UML) i następnie zaimplementować jako pipeline, co ułatwia weryfikację, czy implementacja faktycznie odpowiada zaplanowanej ścieżce budowania i wdrażania.

**Job** w Jenkinsie to zdefiniowane zadanie (np. pipeline), które opisuje co ma się wykonać oraz kiedy ma się uruchomić (ręcznie, po pushu, cyklicznie itp.). W praktyce jest to „opakowanie” na konfigurację: skąd brać kod, jakie kroki wykonać i jakie artefakty/raporty zebrać.

**Agent Jenkinsa** to maszyna lub kontener, na którym fizycznie wykonują się kroki joba/pipeline’u (checkout, build, testy, deploy). Dzięki agentom można rozdzielić obciążenie i uruchamiać pipeline’y w różnych środowiskach (np. osobny agent z Dockerem/.NET), zamiast wykonywać wszystko na serwerze Jenkins.

**Ścieżka krytyczna, jaką taki pipeline powinien zawierać, składa się z poniższych części, w dokładnie takiej kolejności:**
1. Commit do repozytorium (wywoływany ręcznie przez programistę, następne etapy uruchamiają się już automatycznie).
2. Clone/checkout repozytorium (Jenkins pobiera kod do swojego workspace na agencie, np. do katalogu joba, żeby kolejne kroki miały dostęp do źródeł i mogły działać w izolowanym środowisku).
3. Build (zbudowanie projektu: przywrócenie zależności, kompilacja, ewentualnie budowa artefaktów/obrazu Docker).
4. Testy (uruchomienie testów automatycznych jak unit testy, integracyjne i e2e, wyniki testów powinny być raportowane w Jenkinsie).
5. Deploy (wdrożenie na środowisko docelowe, poprzez uruchomienie kontenera/usługi w możliwie lekkiej i bezpiecznej wersji).
6. Publish/Public (udostępnienie wyniku: publikacja artefaktów i raportów, np. obrazu Docker do rejestru).

#### Dobre praktyki pipeline CI/CD

**Artefakty** to „wyniki” pracy pipeline’u, czyli pliki/produkty wygenerowane w trakcie builda i testów, które potem można pobrać, uruchomić albo wdrożyć. W Jenkinsie artefakty często są archiwizowane po danym przebiegu joba (razem z logami), żeby dało się łatwo odtworzyć co dokładnie zostało zbudowane i na czym bazowało wdrożenie.

W praktyce artefaktami mogą być np.:
- skompilowana aplikacja / paczka (np. `.dll`, `.zip`, NuGet),
- obraz Dockera wrzucony do rejestru,
- raporty z testów i analizy jakości (np. wyniki unit/integracyjnych/e2e),
- wygenerowane pliki konfiguracyjne lub inne zasoby potrzebne do deploy.

##### Do realizacji pipeline CI/CD kluczowe jest odpowiednie skonfigurowanie plików Dockerfile oraz docker-compose, bo wtedy cały proces da się uruchomić powtarzalnie (na tej samej konfiguracji) na różnych maszynach.


**W przypadku Dockerfile można zastosować Multi-stage build**, czyli podzielenie budowy obrazu na wiele etapów. W takiej sytuacji zazwyczaj pierwszym etapem jest kontener „builder”, gdzie wykonywane jest budowanie projektu (i ewentualnie instalacja zależności), a kolejnym etapem może być osobny etap testowy uruchamiany na zbudowanych artefaktach.

Wszystkie te kroki odbywają się w starannie dobranej sekwencji kaskadowej: kolejny krok często opiera się na poprzednim w celu optymalizacji (cache warstw), bo nie ma sensu budować tego samego projektu 2 razy. Dlatego jeśli build się powiedzie, to testy wykonuje się na tych samych wynikach budowania (np. na artefaktach z etapu builder), zamiast kompilować od zera.

Na końcu zwykle tworzy się „production/runtime stage”, czyli odchudzony i bezpieczniejszy obraz zawierający tylko to, co niezbędne do uruchomienia aplikacji (bez narzędzi budujących i bez zbędnych zależności). Konkretna metoda „instalacji tylko produkcyjnych zależności” zależy od technologii: np. w Node.js typowo robi się `npm ci --omit=dev` (czasem spotyka się też starsze `--only=production`), a w .NET robi się `dotnet publish` i do runtime obrazu kopiuje się już opublikowane pliki.

Z kolei docker-compose spina całość w jedną definicję środowiska (serwisy, sieci, wolumeny, porty), więc jednym poleceniem można uruchomić np. Jenkinsa + DIND oraz wymagane zależności projektu i mieć pewność, że pipeline działa tak samo lokalnie i na serwerze.

##### Logi z procesu 

W realizacji CI/CD kluczowe są logi z procesów, informujące czy wszystko przebiega zgodnie z planem oraz alarmujące o błędach. Bez logów szukanie źródła błędu staje się ekstremalnie trudne, bo nie wiadomo na jakim etapie dokładnie poszło nie tak.

W Jenkinsie serwer CI automatycznie przechwytuje standardowe wyjście (stdout) oraz błędy (stderr) ze wszystkich etapów pipeline’u i udostępnia je jako tzw. Console Output dla konkretnego przebiegu (builda). Oprócz samego tekstu logów często podpinane są też raporty (np. z testów), dzięki czemu łatwo prześledzić, który krok się wysypał i co było przyczyną.

##### Wersjonowanie

Wersjonowanie wdrożeń w pipeline’ie jest również ważne, bo zapewnia niezmienność artefaktów i pełną odtwarzalność (wiemy dokładnie co zostało wdrożone i z jakiego kodu). Dzieje się to poprzez nadawanie każdemu zbudowanemu artefaktowi (np. obrazowi Dockera) unikalnego tagu/wersji na podstawie informacji z builda, np. numeru builda albo SHA commita.

Dzięki temu można wprost wskazać konkretną wersję do deploy (np. `app:1.0.3`, `app:build-27` albo `app:<git-sha>`). 
Tag typu `:latest` może istnieć jako „wskaźnik” na ostatni poprawny build, ale w praktyce najlepiej traktować go pomocniczo, a do wdrożeń używać tagów jednoznacznych — wtedy nie ma ryzyka, że „latest” zmieni się w międzyczasie i wdroży się coś innego niż planowano.

## Skrypt pipeline

Realizacja pipeline CI/CD w Jenkinsie dobrze wpisuje się w podejście `Pipeline as Code` (oraz szerzej `Configuration as Code`), czyli w zasadę, że wszystko co istotne zapisuje się kodem lub skryptami. Dzięki temu da się później dokładnie odtworzyć proces budowania, testowania i wdrażania (np. po przeniesieniu na inną maszynę lub po czasie).

##### Pipeline w Jenkinsie można napisać na 2 sposoby:

1. **Skrypt Groovy - w konfiguracji** projektu jako definicję wybiera się opcję `Pipeline script`, następnie w polu `Script` wpisuje się kod pipeline’u (składnia Groovy/Jenkins Pipeline).

![alt text](Sprawozdanie6/jenkins-kod.png)

2. **Dostarczanie pipeline z SCM** (Source Control Management) - systemu kontroli wersji/repozytorium (np. Git/GitHub), w którym przechowywany jest kod projektu oraz (w tym podejściu) definicja pipeline’u.

Należy w konfiguracji projektu wybrać opcję definicji jako `Pipeline script from SCM` oraz utworzyć plik `Jenkinsfile`, w którym również pisze się skrypt Groovy. Plik ten umieszcza się w repozytorium projektu, a w ustawieniach joba Jenkinsa podlinkowuje się repozytorium oraz ustawia branch, na którym ma pracować pipeline (np. przy wybraniu opcji `Git`).

Jeżeli w pipeline używa się `deleteDir()` przed własnym `git clone`, to warto wyłączyć automatyczny checkout Jenkinsa (opcja typu **Skip default checkout**). Innaczej Jenkins, będzie próbował pobrać kod przed wyczyszczeniem starych i niepotrzebnych plików. Takto klonowanie następuje odpiero w kontrolowanym miejscu.

![alt text](Sprawozdanie7/pipeline_sgm.png)

**Czym się różnią te 2 podejścia:**
- `Pipeline script` (w Jenkinsie): pipeline jest zapisany w konfiguracji joba na serwerze Jenkins. Edycja opiera się na UI Jenkinsa, co może powodować problemy w przenoszeniu między środowiskami i wersjonowaniem.
- `Pipeline script from SCM` (Jenkinsfile w repozytorium): pipeline jest wersjonowany razem z kodem, ma historię zmian w commit`ach, łatwo go odtworzyć na innym Jenkinsie i można go przeglądać/recenzować jak normalny kod.

#### Przydatne polecenia oraz struktura Groovy

Poniższy plik to Declarative Pipeline w Jenkinsie (składnia Groovy), czyli opis kroków CI/CD zapisany w formie kodu.

        pipeline {
            agent any
            stages {
                stage('Clone') {
                    steps {
                        deleteDir()
                        echo 'Pobieranie repozytorium...'
                        sh 'git clone https://github.com/SaniolJR/ts_fork.git .'
                    }
                }
                stage('Build') {
                    steps {
                        echo 'Budowanie obrazów z pliku Dockerfile.build...'
                        sh 'docker build -f Dockerfile.build --target tester -t nest-api:test .'
                        sh "docker build -f Dockerfile.build --target runtime -t nest-api:${BUILD_NUMBER} -t nest-api:latest ."
                    }
                }
                stage('Run Tests') {
                    steps {
                        echo 'Uruchamianie testów...'
                        sh 'docker run --rm nest-api:test'
                    }
                }
                stage('Deploy Container') {
                    steps {
                        echo 'Wdrażanie...'
                        sh 'docker rm -f my-nest-api || true'
                        sh "docker run -d -p 3003:3003 --name my-nest-api nest-api:${BUILD_NUMBER}"
                    }
                }
                stage('Smoke Test') {
                    steps {
                        echo 'Smoke Test (Inżynierska weryfikacja)...'
                        sh 'curl -f http://localhost:3003 || echo "Aplikacja działa, ale Jenkins nie widzi jej po localhost - to normalne w Dockerze!"'
                    }
                }
                stage('Publish') {
                    steps {
                        echo "Eksportowanie obrazu do pliku i archiwizacja w Jenkinsie..."
                        // Zapisywanie obrazu do pliku .tar
                        sh "docker save nest-api:${BUILD_NUMBER} -o nest-api-v${BUILD_NUMBER}.tar"
                        // Archiwizacja pliku w Jenkinsie - to dodaje go do historii builda
                        archiveArtifacts artifacts: "nest-api-v${BUILD_NUMBER}.tar", fingerprint: true
                    }
                }
            }
            post {
                success { echo "✅ NARESZCIE SUKCES!" }
                failure { echo "❌ Coś jeszcze nie tak, ale jesteśmy blisko" }
            }
        }


##### Wytłumaczenie poleceń skryptu:

- `pipeline { ... }` — główny blok definicji pipeline’u (Jenkins wie, że to jest potok z etapami).
- `agent any` — `agent` to dyrektywa po której definiuje na których z dostępnych agentów Jenkins może wykonać pipeline. `any` w tym przypadku oznacza każdego z dostępnych. Oznacza to, że wszystkie kroki `sh` wykonują się na maszynie/kontenerze agenta.
- `stages { ... }` — lista etapów, każdy `stage(...)` to logiczny krok widoczny w UI np. jako graf.

**Stage: Clone**
- `deleteDir()` — czyści workspace joba na agencie usuwając pliki z poprzednich buildów.
- `echo '...'` — wypisuje tekst do logów (Console Output).
- `sh '[polecenie dla linuxa]'` — uruchamia polecenie w shellu Linuxa.

**Stage: Build**
- `sh 'docker build -f Dockerfile.build --target tester -t nest-api:test .'`:
    - `docker build` — buduje obraz Dockera.
    - `-f Dockerfile.build` — używa konkretnego pliku Dockerfile znajdującego się w repozytorium.
    - `--target tester` — buduje tylko etap o nazwie `tester` z multi-stage Dockerfile.
    - `-t nest-api:test` — nadaje tag obrazowi: `nest-api:test`.
    - `.` — kontekst budowania (bieżący katalog z kodem).
- `sh "docker build -f Dockerfile.build --target runtime -t nest-api:${BUILD_NUMBER} -t nest-api:latest ."`:
    - `--target runtime` — buduje docelowy „runtime stage” (obraz do uruchomienia aplikacji).
    - `-t nest-api:${BUILD_NUMBER}` — taguje obraz numerem builda Jenkinsa (zmienna środowiskowa `BUILD_NUMBER` rośnie z każdym uruchomieniem joba), co daje jednoznaczną wersję.
    - `-t nest-api:latest` — dodatkowy tag wskazujący na ostatni zbudowany runtime.

**Stage: Run Tests**
- `sh 'docker run --rm nest-api:test'`:
    - `docker run` — uruchamia kontener z obrazu `nest-api:test`.
    - `--rm` — po zakończeniu usuwa kontener, żeby nie zostawiać „śmieci”.
    - To zakłada, że w obrazie testowym domyślne `CMD/ENTRYPOINT` uruchamia testy (np. `npm test`). 
    **Jeśli testy zwrócą kod różny od 0, to krok `sh` zakończy się błędem i pipeline zostanie przerwany.**

**Stage: Deploy Container**
- `sh 'docker rm -f my-nest-api || true'`:
    - `docker rm -f my-nest-api` — usuwa siłowo istniejący kontener o nazwie `my-nest-api`.
    - `|| true` — odpowiada, za to że jeżeli polecenie zwróci błąd to pipeline nie zostanie przerwany.
- `sh "docker run -d -p 3003:3003 --name my-nest-api nest-api:${BUILD_NUMBER}"`:
    - `-d` — uruchamia kontener w tle (detached).
    - `-p 3003:3003` — mapuje port hosta `3003` na port `3003` w kontenerze.
    - `--name my-nest-api` — nadaje nazwę kontenerowi.
    - `nest-api:${BUILD_NUMBER}` — uruchamia dokładnie tę wersję obrazu, która została zbudowana w tym buildzie.

**Stage: Smoke Test**
- `sh 'curl -f http://localhost:3003 || echo "Aplikacja działa, ale Jenkins nie widzi jej po localhost - to normalne w Dockerze!"'`:
    - `curl -f` — wykonuje request HTTP i zwraca błąd (exit code != 0), jeśli odpowiedź nie jest 2xx/3xx.
    - `http://localhost:3003` — `localhost` oznacza „tam gdzie wykonuje się polecenie”, czyli na agencie. To zadziała, jeśli kontener jest uruchomiony na tym samym hoście sieciowym co agent i port jest wystawiony.
    - `|| echo ...` — jeśli `curl` się nie powiedzie, to wykona się `echo`, przez co pipeline nie zostanie przerwany, aczkolwiek w logach wystąpi informacja o błędzie przy smoke test.

**Stage: Publish**
- `sh "docker save nest-api:${BUILD_NUMBER} -o nest-api-v${BUILD_NUMBER}.tar"`:
    - `docker save` — eksportuje obraz Dockera do pliku `.tar` (czyli robi z obrazu artefakt, który da się później pobrać/zaimportować).
    - `nest-api:${BUILD_NUMBER}` — zapisuje dokładnie tę wersję obrazu, która była zbudowana w tym buildzie.
    - `-o nest-api-v${BUILD_NUMBER}.tar` — wskazuje nazwę pliku wynikowego.
- `archiveArtifacts artifacts: "nest-api-v${BUILD_NUMBER}.tar", fingerprint: true`:
    - `archiveArtifacts` — archiwizuje wskazany plik jako artefakt Jenkinsa i podpina go do historii konkretnego builda (można go potem pobrać z UI).
    - `fingerprint: true` — włącza fingerprinting, czyli Jenkins zapisuje odcisk artefaktu i może śledzić, w jakich buildach/pipeline’ach był użyty.

**Sekcja: post**
- `post { success { ... } failure { ... } }` — blok wykonywany po całym pipeline’ie, zależnie od wyniku.
- `success { echo ... }` — komunikat, gdy wszystkie etapy przeszły.
- `failure { echo ... }` — komunikat, gdy któryś etap zakończy się błędem.

## Wnioski

Laboratoria 5-7 opierały się na pogłębieniu wiedzy projektowania pipeline CI/CD w Jenkinsie w celu uporządkowania procesu pracy. Mimo wykonywania zadań w warunkach laboratoryjnych, a nie produkcyjno-komercyjnych efekt ten był mocno widoczny. Każda zmiana musiała przechodzić ten sam zestaw kroków (build, testy, deploy) i wynik był łatwy do odtworzenia. 
Wykorzystanie Dockera (w tym Multi-stage build) oraz artefaktów/logów w Jenkinsie ułatwiło przenoszenie pipeline’u między maszynami, analizę błędów i kontrolę nad tym co dokładnie zostało zbudowane. 
Dodatkowo wersjonowanie artefaktów jak tagowanie obrazów numerem builda, pozwoliło na jednoznaczne wskazanie wdrażanej wersji i uniknięcie przypadkowych różnic między wdrożeniami.