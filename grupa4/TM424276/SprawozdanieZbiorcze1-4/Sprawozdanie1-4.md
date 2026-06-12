# Zbiorcze sprawozdanie z ćwiczeń 1–4


## **1. Wstęp**

Celem zrealizowanego cyklu zajęć laboratoryjnych było praktyczne zapoznanie się z nowoczesnymi narzędziami i metodykami wykorzystywanymi w codziennej pracy programisty oraz inżyniera DevOps. Omawiane zagadnienia tworzyły spójną ścieżkę edukacyjną, obejmującą bezpieczne zarządzanie kodem źródłowym w systemie Git, wykorzystanie asymetrycznej kryptografii SSH, podstawy wirtualizacji na poziomie systemu operacyjnego za pomocą platformy Docker, a także tworzenie powtarzalnych środowisk budowania. Zwieńczeniem prac było zaawansowane operowanie woluminami i sieciami kontenerowymi oraz wdrożenie elementów ciągłej integracji przy użyciu skonteneryzowanego serwera Jenkins.

## **2. Git, gałęzie i SSH**

Git to rozproszony system kontroli wersji, który stanowi absolutny fundament bezpiecznego i uporządkowanego śledzenia zmian w projektach informatycznych. Zamiast operować na pojedynczych plikach, Git zapisuje kompletne migawki stanu repozytorium w postaci zatwierdzeń (commitów). W trakcie zajęć szczególną uwagę zwrócono na bezpieczną komunikację ze zdalnym repozytorium GitHub za pomocą protokołu SSH. Wygenerowanie pary kluczy kryptograficznych – prywatnego i publicznego – umożliwiło bezpieczną, pozbawioną konieczności każdorazowego wpisywania hasła autoryzację, co znacząco podnosi ergonomię pracy.

Praca nad projektem opierała się na izolacji zmian za pomocą gałęzi (branchy), co pozwala na równoległe rozwijanie nowych funkcji bez ingerencji w stabilny kod bazowy. Zmiany realizowano na dedykowanej gałęzi oznaczonej numerem indeksu TM424276. Wykorzystano również mechanizm Git Hooks, wdrażając lokalny skrypt uruchamiany przed każdym zatwierdzeniem, który wymuszał umieszczanie prefiksu z numerem indeksu w wiadomości commita. Integracja gotowych zmian z głównym kodem grupy odbywała się za pośrednictwem Pull Requestów, co w rzeczywistych warunkach umożliwia przeprowadzenie rzetelnego przeglądu kodu przed jego włączeniem.

## **3. Docker i podstawowa praca z kontenerami**

Technologia Docker wprowadziła lżejszą, bardziej skalowalną alternatywę dla klasycznych maszyn wirtualnych. Kontener, w odróżnieniu od maszyny wirtualnej, nie emuluje sprzętu ani nie uruchamia własnego, pełnego systemu operacyjnego, lecz współdzieli jądro systemu gospodarza. Rozróżniono pojęcia statycznego obrazu, będącego szablonem ze wszystkimi niezbędnymi bibliotekami, oraz kontenera, który jest uruchomioną, aktywną instancją tego obrazu. W trakcie ćwiczeń opanowano podstawowe polecenia cyklu życia kontenerów, takie jak pobieranie obrazów, uruchamianie procesów, zatrzymywanie oraz wchodzenie w interakcję z działającym środowiskiem za pomocą terminala.

Kluczowym aspektem zrozumienia architektury kontenerów była analiza roli procesu o identyfikatorze PID 1. Stanowi on główny proces kontenera, a jego zakończenie jest równoznaczne z wyłączeniem całego wyizolowanego środowiska. Pracowano z różnymi typami obrazów, od minimalistycznych dystrybucji systemowych, przez środowiska uruchomieniowe (runtime), aż po kompleksowe narzędzia deweloperskie (SDK). Podstawą automatyzacji tworzenia tych środowisk był plik Dockerfile, stanowiący listę deklaratywnych instrukcji opisujących sposób budowania spersonalizowanych obrazów.

## **4. Budowanie i testowanie oprogramowania w kontenerze**

Zastosowanie kontenerów zostało rozszerzone z samego uruchamiania aplikacji na fazę jej budowania i testowania. Zapewnia to identyczne środowisko kompilacji dla każdego programisty w zespole, uniezależniając proces od lokalnych konfiguracji maszyn roboczych. Wykorzystano narzędzie GNU Make oraz pliki Makefile, aby ustandaryzować wywoływanie poleceń odpowiedzialnych za kompilację kodu oraz uruchamianie testów jednostkowych, co jest kluczowe w procesach CI.

W procesie konteneryzacji zastosowano optymalną architekturę wieloetapowego budowania (multi-stage builds). W pierwszym etapie plik Dockerfile instruował silnik o użyciu obciążonego narzędziami obrazu bazowego do skompilowania programu. Po zakończeniu tego procesu, sam wynikowy plik wykonywalny był kopiowany do drugiego, minimalistycznego obrazu. Zabieg ten drastycznie redukuje objętość finalnego obrazu oraz zwiększa jego bezpieczeństwo. Uzupełnieniem tematu było narzędzie Docker Compose, które poprzez deklaratywny plik YAML umożliwia jednoczesne powoływanie do życia wielu współpracujących kontenerów.

## **5. Woluminy, sieć, usługi i Jenkins**

Czwarte zajęcia praktyczne skoncentrowały się na trwałości danych i zaawansowanej komunikacji. Ze względu na ulotność systemów plików w kontenerach, wdrożono mechanizm woluminów do zachowywania stanu operacji. Użyto jednorazowego kontenera pomocniczego do sklonowania repozytorium bezpośrednio na wolumin wejściowy, co pozwoliło utrzymać czystość głównego środowiska budującego. Przeanalizowano również instrukcję montowania punktowego podczas budowania obrazów, która optymalizuje zarządzanie kodem źródłowym na etapie kompilacji.

W ramach analizy sieciowej zbadano przepustowość przy pomocy narzędzia IPerf3. Testy wykazały znakomite parametry transferu rzędu 80 gigabitów na sekundę, co potwierdza wysoką wydajność komunikacji wewnątrz pamięci hosta. Skonfigurowano własną sieć mostkową, co umożliwiło kontenerom niezawodną komunikację z wykorzystaniem nazw (rozwiązywanie DNS), zamiast trudnych do zarządzania, dynamicznych adresów IP. Uruchomiono również usługę SSHD, diagnozując to podejście jako obarczone wadami ze względu na naruszenie zasady jednego procesu na kontener, jednak bywa ono przydatne przy migracji starszych architektur systemowych.

Ostatnim elementem było wdrożenie serwera ciągłej integracji Jenkins w oparciu o architekturę Docker-in-Docker (DinD). Skonfigurowano środowisko, w którym skonteneryzowany Jenkins posiada uprawnienia do powoływania kolejnych kontenerów niezbędnych do wykonywania poszczególnych zadań potoków CI/CD. Rozwiązanie to gwarantuje pełną izolację kolejnych iteracji budowania oprogramowania.

## **6. Wnioski końcowe**

Cykl ćwiczeń laboratoryjnych pozwolił na zbudowanie solidnych podstaw do pracy w nowoczesnych środowiskach informatycznych zorientowanych na podejście DevOps. Poznane mechanizmy – od kontroli wersji w systemie Git, przez izolację środowisk i standaryzację wdrożeń oferowaną przez system Docker, po fundamenty automatyzacji w serwerze Jenkins – stanowią dzisiaj standard rynkowy. Dogłębne zrozumienie tych narzędzi, w szczególności zarządzania procesami kompilacji, sieciami kontenerowymi i trwałością danych, jest absolutnie niezbędne do tworzenia bezpiecznych, niezawodnych i powtarzalnych procesów wytwarzania i dostarczania oprogramowania.