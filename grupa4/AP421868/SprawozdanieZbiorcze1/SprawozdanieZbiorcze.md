# Zbiorcze sprawozdanie z ćwiczeń 1–4

## 1. Wstęp

Celem zajęć było zapoznanie się z podstawowymi narzędziami wykorzystywanymi w pracy programisty i administratora środowisk CI/CD. Omawiane zagadnienia obejmowały zarządzanie kodem źródłowym w Git, korzystanie z uwierzytelniania SSH, podstawy pracy z Dockerem, tworzenie powtarzalnych środowisk budowania, wykorzystanie woluminów i sieci kontenerowych oraz uruchamianie dodatkowych usług, takich jak SSHD i Jenkins.

---

## 2. Git, gałęzie i SSH

Git jest rozproszonym systemem kontroli wersji, który służy do śledzenia zmian w kodzie źródłowym oraz współpracy wielu osób nad jednym projektem. Pozwala zapisywać kolejne wersje plików w postaci commitów, tworzyć gałęzie i scalać zmiany w kontrolowany sposób. W praktyce Git umożliwia zachowanie historii projektu, łatwe cofanie zmian oraz bezpieczną pracę zespołową.

Jedną z podstawowych operacji jest klonowanie repozytorium za pomocą `git clone`. Polecenie to pobiera pełną kopię repozytorium zdalnego na lokalny komputer. W zależności od sposobu uwierzytelniania można używać protokołu HTTPS albo SSH. W przypadku HTTPS często stosuje się token dostępu osobistego, natomiast przy SSH autoryzacja odbywa się za pomocą kluczy publiczno-prywatnych. Zaletą SSH jest brak konieczności każdorazowego wpisywania hasła i większa wygoda przy pracy z wieloma repozytoriami.

Ważnym elementem pracy z Git są gałęzie. Polecenie `git checkout -b nazwa` tworzy nową gałąź i od razu przełącza na nią użytkownika. Dzięki gałęziom można rozwijać nowe funkcje niezależnie od głównej linii kodu. Następnie zmiany dodaje się poleceniem `git add`, zatwierdza przez `git commit -m "opis"` i wysyła do repozytorium zdalnego przez `git push`. Z kolei `git pull` służy do pobierania i scalania zmian z gałęzi zdalnej do lokalnej kopii. W pracy zespołowej bardzo ważne jest także tworzenie pull requestów, czyli propozycji włączenia zmian z jednej gałęzi do drugiej po wcześniejszym przejrzeniu kodu.

W ćwiczeniu poruszono również temat Git hooków. Jest to mechanizm umożliwiający automatyczne uruchamianie skryptów w określonych momentach, na przykład przed commitem. W tym przypadku hook służył do sprawdzania, czy wiadomość commita zaczyna się od ustalonego prefiksu. Takie rozwiązanie poprawia spójność historii projektu i wymusza ustalony standard pracy.

Osobnym zagadnieniem było SSH. Protokół ten służy do bezpiecznego zdalnego logowania i pracy z systemami Unix/Linux. Generowanie kluczy odbywa się najczęściej poleceniem `ssh-keygen`, które tworzy parę kluczy: prywatny i publiczny. Klucz publiczny można dodać do serwisu GitHub jako metodę uwierzytelniania. W praktyce SSH jest znacznie wygodniejsze niż uwierzytelnianie hasłem, a dodatkowo umożliwia korzystanie z podpisanej kryptograficznie komunikacji.

---

## 3. Docker i podstawowa praca z kontenerami

Docker jest platformą do tworzenia, uruchamiania i zarządzania kontenerami. Kontener można rozumieć jako lekki, odizolowany proces działający w systemie hosta, ale mający własne środowisko plików, biblioteki i konfigurację. W odróżnieniu od klasycznej maszyny wirtualnej kontener nie uruchamia pełnego systemu operacyjnego, tylko korzysta z jądra systemu gospodarza. Dzięki temu jest lżejszy, uruchamia się szybciej i łatwiej go powielać.

Podstawowym pojęciem jest obraz Dockera. Obraz to niezmienny szablon środowiska, z którego uruchamia się kontener. Kontener jest natomiast działającą instancją tego obrazu. Obrazy pobiera się z rejestrów, np. Docker Hub, za pomocą `docker pull`, a uruchamia poleceniem `docker run`. Komenda `docker images` pokazuje dostępne obrazy, `docker ps -a` wyświetla wszystkie kontenery, `docker stop` zatrzymuje kontener, a `docker rm` usuwa jego definicję. Z kolei `docker exec -it` pozwala wejść do działającego kontenera i uruchomić w nim dodatkową powłokę.

W trakcie zajęć analizowano obrazy takie jak `hello-world`, `busybox`, `ubuntu`, `mariadb`, `runtime`, `aspnet` i `sdk`. Każdy z nich pokazuje inny sposób budowy środowiska kontenerowego. `hello-world` służy głównie do testu poprawności instalacji, `busybox` to bardzo mały obraz zawierający podstawowe narzędzia systemowe, `ubuntu` reprezentuje pełniejsze środowisko systemowe, a obrazy `sdk` i `runtime` pokazują rozdzielenie etapu budowania aplikacji od jej uruchamiania. Dzięki temu łatwo zrozumieć, że obraz może być minimalny albo bogaty w narzędzia w zależności od przeznaczenia.

Ważnym zagadnieniem była również rola procesu PID 1 w kontenerze. W systemach Unix/Linux pierwszy proces ma szczególne znaczenie, ponieważ odpowiada za start środowiska i przejmowanie sygnałów systemowych. W kontenerze często jest nim powłoka albo aplikacja główna. Z tego powodu sposób uruchamiania kontenera ma znaczenie dla jego poprawnego działania i zamykania.

Kolejny istotny element to plik `Dockerfile`. Jest to instrukcja opisująca, jak zbudować własny obraz. Zawiera m.in. wybór obrazu bazowego, instalację pakietów, kopiowanie plików i wskazanie polecenia uruchamiającego kontener. Polecenie `docker build` tworzy obraz na podstawie takiego pliku, a późniejsze `docker run` uruchamia gotowe środowisko. Dockerfile jest więc podstawą automatyzacji i powtarzalności.

---

## 4. Budowanie i testowanie oprogramowania w kontenerze

Trzecie ćwiczenie koncentrowało się na tym, że kontener może służyć nie tylko do uruchamiania aplikacji, ale również do jej budowania i testowania. Jest to szczególnie ważne w środowiskach CI, gdzie zależy nam na powtarzalnym wyniku niezależnie od maszyny, na której wykonywany jest proces.

Proces budowania w projekcie opiera się na pliku `Makefile`, a podstawowe polecenie `make` uruchamia kompilację zgodnie z określonymi regułami. Z kolei `make test` uruchamia zestaw testów jednostkowych. Takie podejście rozdziela budowanie i weryfikację jakości kodu. Testy są ważne, ponieważ pozwalają sprawdzić, czy zmiany nie zepsuły działania programu.

W kontenerach szczególnie dobrze sprawdza się podejście wieloetapowe. Pierwszy obraz może zawierać wszystkie narzędzia potrzebne do budowania projektu, natomiast drugi może bazować na pierwszym i uruchamiać już tylko testy. Taki podział zmniejsza powtarzalność błędów i pozwala odseparować środowisko kompilacji od środowiska uruchomieniowego.

Docker Compose rozszerza to podejście o możliwość opisania kilku kontenerów w jednym pliku konfiguracyjnym. Dzięki temu można uruchomić cały zestaw usług jednym poleceniem, np. `docker compose up --build`. Compose jest wygodny szczególnie wtedy, gdy projekt składa się z kilku współpracujących komponentów. Zamiast ręcznie uruchamiać każdy kontener osobno, można zdefiniować całą kompozycję jako spójne środowisko.

---

## 5. Woluminy, sieć, usługi i Jenkins

Czwarte ćwiczenie poruszało tematy związane z trwałością danych, komunikacją sieciową i uruchamianiem usług w kontenerach. Jednym z najważniejszych zagadnień były woluminy. Wolumin pozwala zachować dane poza cyklem życia kontenera, dzięki czemu można odtworzyć stan środowiska lub przekazywać dane między różnymi uruchomieniami. W praktyce stosuje się zarówno bind mounty, czyli podłączenie katalogu z hosta, jak i woluminy zarządzane przez Dockera.

Bind mount jest prosty i wygodny, gdy chcemy udostępnić kontenerowi istniejący katalog z systemu hosta. Docker volume daje większą niezależność od struktury hosta i lepiej nadaje się do danych, którymi zarządza sam Docker. W teorii obie metody służą do tego samego: oddzielenia danych od cyklu życia kontenera. To szczególnie ważne w przypadku kodu źródłowego, wyników kompilacji lub danych aplikacji.

Istotne były również sieci kontenerowe. Domyślna sieć `bridge` pozwala kontenerom komunikować się ze sobą przez adresy IP. Tworząc własną sieć mostkową, można dodatkowo korzystać z wbudowanego w Docker DNS, który rozwiązuje nazwy kontenerów. To znacząco upraszcza konfigurację, bo nie trzeba ręcznie sprawdzać adresów IP. Komendy takie jak `docker network create` służą właśnie do organizowania takiej komunikacji. Dodatkowo `-p` w `docker run` pozwala wystawić port kontenera na hosta, dzięki czemu usługa działająca wewnątrz kontenera staje się dostępna także z zewnątrz.

Do testowania przepustowości użyto narzędzia `iperf3`. Pozwala ono sprawdzić jakość połączenia sieciowego między dwoma punktami i ocenić wydajność transmisji. Tego typu testy pokazują, że kontenery mogą komunikować się zarówno lokalnie w obrębie jednej maszyny, jak i przez interfejs hosta.

W ćwiczeniu pojawiła się także usługa SSHD uruchomiona wewnątrz kontenera. SSH w kontenerze z jednej strony umożliwia klasyczną administrację zdalną, z drugiej narusza zasadę jednego procesu na kontener i zwiększa powierzchnię ataku. Może być jednak użyteczne w sytuacjach, gdy potrzebne są tradycyjne narzędzia administracyjne lub integracja z istniejącą infrastrukturą.

Ostatnim elementem był Jenkins uruchomiony w modelu skonteneryzowanym z pomocą DIND, czyli Docker-in-Docker. Jenkins to popularny serwer CI/CD służący do automatyzacji budowania, testowania i wdrażania oprogramowania. Wersja kontenerowa ułatwia szybkie odtworzenie środowiska i integrację z innymi usługami. Z kolei pomocnik DIND zapewnia możliwość wykonywania operacji Dockera wewnątrz środowiska Jenkins, co jest przydatne w pipeline’ach automatyzujących budowę obrazów.

---

## 6. Wnioski końcowe

Zrealizowane ćwiczenia tworzą spójny wstęp do pracy z nowoczesnymi narzędziami DevOps. Git pozwala zarządzać kodem i współpracować w zespole, SSH zapewnia bezpieczne uwierzytelnianie, Docker daje możliwość izolacji i powtarzalności środowiska, a woluminy i sieci kontenerowe umożliwiają budowę bardziej złożonych systemów. Z kolei Jenkins pokazuje, jak z tych elementów złożyć praktyczne środowisko automatyzacji CI/CD.