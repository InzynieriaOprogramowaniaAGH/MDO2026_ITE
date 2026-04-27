# Sprawozdanie zbiorcze — laboratoria 5–7

*Kacper Szlachta 422031*

## 1. Wstęp

Laboratoria 5–7 koncentrowały się na przygotowaniu i rozwinięciu środowiska Jenkins oraz zbudowaniu kompletnego procesu CI/CD dla niewielkiego projektu w języku C. W pierwszym etapie przygotowano własny obraz kontrolera Jenkins współpracującego z usługą Docker-in-Docker, a następnie wykonano podstawowe zadania potwierdzające poprawność działania pipeline. Kolejne zajęcia rozszerzały to środowisko do postaci pełnego, powtarzalnego procesu obejmującego pobranie kodu, budowanie, testowanie, pakowanie artefaktu, wdrożenie do lekkiego kontenera uruchomieniowego, wykonanie smoke testu oraz publikację rezultatów.

Całość stanowiła praktyczne przejście od ręcznie uruchamianych poleceń kontenerowych do wersjonowanego i zautomatyzowanego procesu zapisanego w Jenkinsfile, uruchamianego bezpośrednio z repozytorium.

Z perspektywy metodyki DevOps był to bardzo istotny etap, ponieważ wcześniejsze laboratoria skupiały się głównie na przygotowaniu środowiska, kontenerów i podstawowych mechanizmów budowania, natomiast tutaj ciężar pracy został przesunięty na automatyzację, powtarzalność i kontrolę jakości procesu. Ćwiczenia pokazały, że samo przygotowanie działającego projektu nie jest wystarczające, jeżeli nie da się go w prosty sposób odtworzyć, przetestować i wdrożyć w przewidywalnym środowisku.

Szczególnie ważne było również to, że wszystkie etapy dotyczyły rzeczywistego przepływu pracy znanego z praktyki inżynierskiej. Zamiast wykonywać odizolowane polecenia jednorazowo, kolejne laboratoria prowadziły do zbudowania spójnego procesu, w którym każdy krok miał jasno określone wejście, rezultat i uzasadnienie. Dzięki temu końcowe sprawozdanie nie opisuje wyłącznie zestawu komend, ale pokazuje, w jaki sposób krok po kroku powstaje podstawowa infrastruktura Continuous Integration i Continuous Delivery.

## 2. Zastosowane technologie i przebieg prac

### a) Przygotowanie środowiska Jenkins i pierwsze pipeline'y (lab5)

Piąte laboratorium rozpoczęto od weryfikacji środowiska utworzonego na poprzednich zajęciach. Sprawdzono obecność obrazów związanych z wcześniejszym procesem build/test oraz działanie kontenerów wymaganych do pracy z Jenkins i Dockerem. Był to punkt wyjścia do budowy własnego środowiska CI.

![Lista obrazów i kontenerów](../Sprawozdanie5/ss/docker_images.png)

Następnie utworzono sieć jenkins oraz wolumeny przechowujące dane i certyfikaty. W ich obrębie uruchomiono kontener jenkins-docker oparty na obrazie docker:dind, działający w trybie uprzywilejowanym. Rozwiązanie to zapewniło oddzielny silnik Docker, z którego mógł korzystać kontroler Jenkins.

Taki sposób organizacji środowiska ma duże znaczenie praktyczne. Zamiast uruchamiać Jenkinsa bezpośrednio na hoście i dawać mu lokalny dostęp do demona Docker, zastosowano model z osobnym kontenerem Docker-in-Docker. Dzięki temu wyraźnie oddzielono warstwę sterującą od warstwy wykonawczej. Kontener jenkins-blueocean odpowiadał za logikę pipeline, natomiast jenkins-docker dostarczał silnik potrzebny do budowania obrazów i uruchamiania kolejnych kontenerów. Taki układ upraszcza zarządzanie uprawnieniami i dobrze wpisuje się w kontenerowy charakter całego środowiska.

![Przygotowanie środowiska DIND](../Sprawozdanie5/ss/dockerfile_jenkins.png)

Kolejnym krokiem było przygotowanie własnego obrazu Jenkins na bazie jenkins/jenkins:lts-jdk17. Do obrazu doinstalowano klienta docker.io oraz wymagane wtyczki, między innymi blueocean i docker-workflow. Po zbudowaniu obrazu uruchomiono kontener jenkins-blueocean z odpowiednimi zmiennymi środowiskowymi DOCKER_HOST, DOCKER_CERT_PATH i DOCKER_TLS_VERIFY, dzięki czemu kontroler mógł komunikować się z usługą Docker-in-Docker.

Przygotowanie własnego obrazu miało istotną zaletę względem korzystania z obrazu domyślnego. Pozwalało od razu osadzić w nim potrzebne narzędzia i wtyczki, dzięki czemu po restarcie lub odtworzeniu kontenera nie było potrzeby ręcznej rekonfiguracji środowiska. Jest to zgodne z podejściem infrastructure as code, w którym nie tylko kod aplikacji, ale także środowisko narzędziowe powinno być możliwie jednoznacznie opisane i powtarzalne.

![Dockerfile dla własnego obrazu Jenkins](../Sprawozdanie5/ss/dockerfile_build.png)
![Budowa i uruchomienie kontrolera Jenkins](../Sprawozdanie5/ss/build_2.png)

Po uruchomieniu środowiska przeprowadzono diagnostykę logów oraz zarejestrowano początkowy problem z zależnościami części wtyczek. Był to ważny etap, ponieważ pokazał, że przygotowanie infrastruktury CI wymaga nie tylko uruchomienia kontenera, ale również weryfikacji poprawności rozszerzeń i ich zgodności wersji.

Ten element ćwiczenia był cenny także z dydaktycznego punktu widzenia. W praktyce systemy CI/CD rzadko działają poprawnie od razu po uruchomieniu, zwłaszcza gdy korzystają z dodatkowych pluginów i integracji. Analiza logów oraz rozpoznanie źródła problemu pokazały, że administracja narzędziami automatyzacji obejmuje również diagnozowanie błędów środowiskowych, a nie wyłącznie pisanie samego pipeline.

![Logi kontrolera Jenkins](../Sprawozdanie5/ss/docker_logs.png)
![Problem z wtyczkami](../Sprawozdanie5/ss/error_jenskins.png)

Po przygotowaniu środowiska wykonano kilka prostych zadań testowych w postaci obiektów typu pipeline. Pierwszy z nich wykonywał uname -a, drugi zwracał błąd przy nieparzystej godzinie systemowej, a trzeci sprawdzał możliwość wykonania polecenia docker pull ubuntu. Dzięki temu potwierdzono, że Jenkins poprawnie uruchamia polecenia powłoki, potrafi sygnalizować sukces i porażkę oraz ma dostęp do silnika Docker.

Były to pozornie bardzo proste zadania, jednak pełniły ważną rolę walidacyjną. Pipeline uname -a sprawdzał podstawową zdolność uruchamiania poleceń powłoki i odczytu środowiska. Zadanie zależne od parzystości godziny weryfikowało obsługę kodów wyjścia i statusów SUCCESS oraz FAILURE. Z kolei docker pull ubuntu potwierdzał, że Jenkins nie tylko wykonuje polecenia lokalne, ale też rzeczywiście może sterować zewnętrznym silnikiem Docker i komunikować się z rejestrem obrazów.

![Pipeline uname](../Sprawozdanie5/ss/uname_script.png)
![Wynik pipeline uname](../Sprawozdanie5/ss/uname_console.png)
![Pipeline docker pull ubuntu](../Sprawozdanie5/ss/pull_console.png)

W dalszej części laboratorium utworzono właściwy pipeline budujący obraz na podstawie grupa6/KS422031/Sprawozdanie3/Dockerfile.build. Pipeline pobierał repozytorium, przełączał się na gałąź KS422031, wyszukiwał odpowiedni plik Dockerfile, a następnie budował obraz lab5-builder:latest. Dwukrotne poprawne uruchomienie zadania potwierdziło jego powtarzalność.

Był to pierwszy moment, w którym Jenkins został wykorzystany do realizacji rzeczywistego zadania inżynierskiego związanego z kodem projektu, a nie jedynie do testów administracyjnych. Sam etap budowania obrazu wymagał poprawnego pobrania repozytorium, odnalezienia pliku budującego i uruchomienia odpowiedniej komendy docker build. Dzięki temu laboratorium piąte można traktować jako etap przejściowy pomiędzy konfiguracją narzędzia a wykorzystaniem go w praktyce do automatyzacji procesu wytwórczego.

![Skrypt właściwego pipeline](../Sprawozdanie5/ss/lab5_script.png)
![Log udanego wykonania pipeline](../Sprawozdanie5/ss/lab5_console.png)
![Powtórzone poprawne uruchomienia](../Sprawozdanie5/ss/2xSucces.png)

### b) Rozszerzenie do pełnej ścieżki CI/CD (lab6)

Szóste laboratorium polegało na rozbudowie wcześniejszego rozwiązania do postaci pełnej ścieżki krytycznej: commit/manual trigger, clone, build, test, package, deploy i publish. Jako aplikację wykorzystano projekt rikusalminen/makefile-for-c, który buduje się z użyciem Makefile i zawiera testy jednostkowe.

Wybór takiej aplikacji był uzasadniony dydaktycznie i technicznie. Projekt był niewielki, czytelny i możliwy do zbudowania w kontrolowanym środowisku, a jednocześnie zawierał wszystkie elementy potrzebne do zaprojektowania pełnego pipeline: kod źródłowy, kroki budowania, testy oraz wynikowy plik wykonywalny. Dzięki temu można było skupić się na strukturze procesu CI/CD, a nie na rozwiązywaniu problemów specyficznych dla skomplikowanej aplikacji.

Na początku sprawdzono, jaki artefakt powstaje po kompilacji. W obrazie buildowym zidentyfikowano plik wykonywalny foo-test, który został przyjęty jako główny rezultat procesu budowania. Następnie przygotowano lekki plik Dockerfile.runtime, którego zadaniem było uruchomienie gotowej binarki bez obecności narzędzi kompilacyjnych.

To rozdzielenie było istotne z punktu widzenia dobrych praktyk konteneryzacji. Obraz budujący może być stosunkowo duży i zawierać kompilator, nagłówki oraz inne zależności potrzebne jedynie podczas kompilacji. Obraz runtime powinien być natomiast możliwie prosty, lekki i ograniczony do minimum koniecznego do uruchomienia programu. Taki podział poprawia przejrzystość procesu, skraca czas wdrożenia i zmniejsza powierzchnię potencjalnych problemów bezpieczeństwa.

![Artefakt foo-test w obrazie build](../Sprawozdanie6/ss/foo_test.png)
![Treść Dockerfile.runtime](../Sprawozdanie6/ss/dockerfile.png)

Lokalnie zbudowano i uruchomiono testowy obraz runtime, aby jeszcze przed integracją z Jenkinsem potwierdzić poprawność sposobu wdrożenia. Dzięki temu wiadomo było, że sam artefakt i kontener uruchomieniowy działają poprawnie.

Była to forma wstępnej walidacji założeń przed osadzeniem ich w pipeline. Takie podejście ogranicza ryzyko, że błędy związane z obrazem runtime zostaną pomylone z błędami konfiguracji Jenkinsa. Najpierw zweryfikowano więc sam mechanizm wdrażania lokalnie, a dopiero później włączono go do automatycznego procesu.

![Lokalny build obrazu runtime](../Sprawozdanie6/ss/docker_build.png)
![Lokalne uruchomienie kontenera runtime](../Sprawozdanie6/ss/docker_run.png)

Kolejny etap stanowiło przygotowanie Jenkinsfile, który opisywał kompletny pipeline. W pliku zdefiniowano nazwy obrazów, zasady wersjonowania artefaktów przy pomocy BUILD_NUMBER oraz podział na osobne etapy: budowanie, testowanie, pakowanie, wdrożenie, smoke test i publikację. Dodatkowo przygotowano plik artifact-info.txt, który dokumentował pochodzenie artefaktu i sposób jego wersjonowania.

Wprowadzenie Jenkinsfile miało znaczenie wykraczające poza samą wygodę. Definicja pipeline w postaci pliku umożliwia jego przeglądanie, edycję i wersjonowanie tak samo jak kodu źródłowego. Możliwe staje się śledzenie zmian, przywracanie wcześniejszych wersji oraz łatwiejsze wdrażanie dobrych praktyk zespołowych. Z kolei artifact-info.txt był przykładem świadomego dokumentowania pochodzenia artefaktu, co ma znaczenie przy diagnostyce, audycie lub późniejszym utrzymaniu procesu.

![Lokalny Jenkinsfile](../Sprawozdanie6/ss/jenkinsfile.png)
![Wersja pipeline w Jenkins](../Sprawozdanie6/ss/pipeline_script.png)
![Opis pochodzenia artefaktu](../Sprawozdanie6/ss/artifact.png)

W części wykonawczej Jenkins pobierał repozytorium i budował obraz lab6-build:latest z użyciem Dockerfile.build. Następnie tworzony był obraz testowy oparty na obrazie buildowym i uruchamiane były testy. W kolejnym kroku z obrazu build kopiowano plik foo-test, nadawano mu prawa wykonania i pakowano go do archiwum tar.gz.

Warto zauważyć, że każdy z tych kroków miał odmienny cel i odpowiedzialność. Etap clone zapewniał świeżą kopię repozytorium, build tworzył środowisko kompilacyjne i generował wynik budowania, test weryfikował poprawność programu, natomiast package przygotowywał artefakt do przeniesienia poza kontekst obrazu budującego. Takie uporządkowanie procesu jest podstawą późniejszej skalowalności pipeline, ponieważ pozwala łatwiej modyfikować lub rozszerzać poszczególne etapy bez naruszania całej struktury.

Wdrożenie polegało na wygenerowaniu lekkiego Dockerfile.runtime, zbudowaniu obrazu lab6-runtime:${BUILD_NUMBER} oraz uruchomieniu kontenera wykonującego skompilowaną aplikację. Po wdrożeniu wykonywano prosty smoke test przez sprawdzenie stanu kontenera i zapisanie logów do pliku numerowanego numerem buildu. Ostatni etap obejmował archiwizację artefaktów w Jenkinsie wraz z fingerprintingiem.

Szczególnie istotny był tu etap publish, ponieważ zamykał cały proces nie tylko od strony technicznego wykonania, ale również od strony zarządzania rezultatami. Archiwizacja artefaktów powoduje, że rezultat działania pipeline nie znika po zakończeniu buildu, lecz staje się trwałym elementem historii projektu. Fingerprinting dodatkowo pozwala identyfikować konkretne pliki w późniejszych przebiegach i wiązać je z określonym numerem wykonania.

![Archiwizacja i logi artefaktów](../Sprawozdanie6/ss/logs.png)

Laboratorium to pokazało praktyczną różnicę między obrazem buildowym, testowym i runtime. Obraz buildowy zawierał pełne środowisko kompilacyjne, testowy służył do weryfikacji poprawności działania programu, natomiast runtime ograniczał się wyłącznie do uruchomienia gotowego artefaktu.

Dzięki temu zajęcia szóste były pierwszym pełnym przykładem procesu CI/CD opartego na świadomym przepływie artefaktu pomiędzy kolejnymi fazami. Zbudowany program nie kończył swojego życia na etapie testów, ale przechodził dalej do pakowania, wdrażania i publikacji, co dobrze oddaje praktyczne znaczenie automatyzacji w nowoczesnym procesie wytwarzania oprogramowania.

### c) Pipeline jako kod w repozytorium i pełna automatyzacja (lab7)

Siódme laboratorium porządkowało i finalizowało wcześniej przygotowany proces. Kluczową zmianą było przeniesienie definicji pipeline do repozytorium w postaci pliku Jenkinsfile wykorzystywanego przez zadanie typu pipeline (SCM). Dzięki temu konfiguracja procesu budowania stała się częścią kodu projektu, mogła być wersjonowana i uruchamiana wielokrotnie bez ręcznego przepisywania skryptu do panelu Jenkins.

Był to krok bardzo istotny organizacyjnie. Pipeline zapisany jedynie w interfejsie Jenkinsa jest trudniejszy do utrzymania, mniej przejrzysty i bardziej podatny na rozbieżności między stanem serwera a stanem repozytorium. Umieszczenie Jenkinsfile bezpośrednio w projekcie oznacza, że konfiguracja procesu budowania podlega tym samym zasadom kontroli wersji co reszta kodu. Dzięki temu łatwiej ją przeglądać, poprawiać i rozwijać.

![Konfiguracja zadania pipeline SCM](../Sprawozdanie7/ss/config.png)

Po stronie wykonawczej pipeline rozpoczynał się od czyszczenia przestrzeni roboczej i pobrania aktualnej wersji repozytorium z właściwej gałęzi. Następnie budowany był obraz lab7-build:latest, a z niego wyprowadzany był osobny obraz testowy uruchamiający make test. Rozdzielenie etapu build i test pozwalało utrzymać czytelny podział odpowiedzialności między kolejnymi krokami.

Usunięcie poprzedniej zawartości workspace przed pobraniem kodu miało znaczenie dla powtarzalności procesu. Chroniło to pipeline przed przypadkowym wykorzystaniem starych plików lub danych pozostających po wcześniejszych wykonaniach. W ten sposób zapewniano, że każdy przebieg jest oparty na aktualnym stanie repozytorium, a nie na lokalnym stanie pamięci roboczej serwera.

![Build obrazu](../Sprawozdanie7/ss/build.png)
![Test obrazu](../Sprawozdanie7/ss/test.png)

Po poprawnym przejściu testów pipeline kopiował artefakt foo-test z obrazu buildowego, pakował go oraz budował lekki obraz runtime przeznaczony do wdrożenia. Następnie uruchamiano kontener docelowy i weryfikowano jego działanie w prostym smoke teście. Poprawny status Exited (0) oznaczał, że program uruchomił się i zakończył bez błędów.

Ten etap dobrze pokazywał, że wynik pracy pipeline nie musi ograniczać się wyłącznie do komunikatu o powodzeniu buildu. Ostatecznym celem procesu jest powstanie rezultatu, który można uruchomić lub przekazać dalej. W tym przypadku takim rezultatem był zarówno spakowany plik wykonywalny, jak i gotowy obraz runtime, który dało się uruchomić jako końcowy produkt procesu budowania.

![Pakowanie artefaktu](../Sprawozdanie7/ss/package.png)
![Wdrożenie kontenera runtime](../Sprawozdanie7/ss/deploy.png)
![Smoke test](../Sprawozdanie7/ss/smokessuccess.png)

Ostatni etap stanowiła publikacja rezultatów w Jenkinsie. Artefakty i logi były dołączane do historii builda, a kolejne wykonania pipeline kończyły się statusem SUCCESS, co potwierdzało stabilność i powtarzalność rozwiązania.

Powtarzalność była tutaj jednym z najważniejszych kryteriów jakości. Pipeline, który działa tylko raz w ściśle określonych warunkach, nie spełnia swojej roli. Dopiero możliwość wielokrotnego uruchamiania tego samego procesu z uzyskaniem poprawnego rezultatu potwierdza, że rozwiązanie zostało przygotowane właściwie. Z tego punktu widzenia laboratorium siódme nie tyle wprowadzało nową funkcjonalność, co konsolidowało i stabilizowało cały wcześniejszy dorobek.

![Poprawnie zakończone przebiegi pipeline](../Sprawozdanie7/ss/successes.png)

Laboratorium siódme domykało tym samym przejście od prostego, ręcznie definiowanego pipeline do pełnego procesu CI/CD zarządzanego z repozytorium i gotowego do wielokrotnego użycia.

## 3. Wnioski

Laboratoria 5–7 tworzyły spójny ciąg prowadzący od przygotowania infrastruktury Jenkins do zbudowania kompletnego i wersjonowanego procesu CI/CD. Najpierw konieczne było poprawne uruchomienie środowiska współpracującego z Docker-in-Docker, a następnie potwierdzenie, że Jenkins może wykonywać zarówno proste polecenia powłoki, jak i bardziej złożone zadania związane z budową obrazów.

Najważniejszym rezultatem całego cyklu było wdrożenie pełnego pipeline obejmującego pobranie kodu, budowę, testy, pakowanie artefaktu, stworzenie lekkiego obrazu runtime, jego uruchomienie oraz publikację rezultatów. Wyraźne rozdzielenie etapów build, test i deploy pozwoliło lepiej kontrolować odpowiedzialność poszczególnych obrazów i ograniczyć końcowe środowisko uruchomieniowe tylko do niezbędnych elementów.

Istotne było również przeniesienie definicji pipeline do repozytorium. Dzięki temu Jenkinsfile stał się częścią projektu, a sam proces budowania zyskał cechy kodu infrastrukturalnego: wersjonowanie, powtarzalność i możliwość wielokrotnego odtwarzania. Całość pokazała, że nawet dla niewielkiej aplikacji konsolowej można zbudować uporządkowany i praktyczny proces CI/CD, który dobrze odzwierciedla rozwiązania stosowane w rzeczywistych projektach.

Dodatkowym wnioskiem płynącym z tych zajęć jest to, że automatyzacja nie polega wyłącznie na skróceniu czasu pracy. Równie ważne są przewidywalność efektów, łatwość diagnostyki i jednoznaczność odpowiedzialności poszczególnych etapów. Dzięki konteneryzacji oraz uporządkowanemu pipeline możliwe stało się oddzielenie środowiska budowania od środowiska uruchomieniowego, a także zachowanie pełnej historii artefaktów i logów.

Zrealizowany ciąg laboratoriów dobrze pokazał również zależność między wcześniejszymi zagadnieniami kursowymi a końcowym efektem. Konfiguracja repozytorium, przygotowanie Dockerfile, budowanie obrazów, woluminy, sieci i podstawy działania Jenkinsa nie były odrębnymi tematami, lecz elementami jednej większej całości. Dopiero połączenie tych składników umożliwiło przygotowanie procesu, który można uznać za uproszczony, ale w pełni funkcjonalny przykład nowoczesnego podejścia DevOps.