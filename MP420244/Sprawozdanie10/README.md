# Kubernetes

Kubernetes jest programem do zarządzania kontenerami na dużą skalę. Oprogramowanie takie jak Docker służy do tworzenia i uruchamiania kontenerów z oprogramowaniem. Kubernetes jest odpowiedzialny za zbudowanie skonfigurowanej infrastruktury, utrzymanie dobrego stanu kontenerów, komunikację między klastrami i zapewnienie skalowalności (w górę i w dół).

## Konfiguracja Minikube

Minikube jest lżejszą alternatywą dla Kubernetesa, uruchamiając tylko jeden klaster. Jest to idealne rozwiązanie dla mniejszych struktur i środowisk o ograniczonych zasobach.

Program uruchamia się poleceniem `minikube start`:

![Uruchomienie klastra](images/1.%20Uruchomienie%20klastra.png)

Tworzy ono kontener z oprogramowaniem Minikube:

![Uruchomiony kontener](images/3.%20Uruchomiony%20kontener.png)

Uruchomione pody Minikube:

![Uruchomione pody](images/2.%20Uruchomione%20serwisy.png)

Pod jest instancją, otaczającą jeden lub kilka kontenerów Dockera, symulującym pojedynczy węzeł sieciowy (np. jedno urządzenie).

## Uruchomienie aplikacji

Programem uruchamianym w Minikube jest atrapa aplikacji webowej, symulującej blog. Składa się ona z frontendu napisanego w typescript, backendu zbudowanego w NestJS i bazy danych MySQL, komunikujących się przez porty lokalnego urządzenia. Żeby aplikacja mogła działać w Minikube, należy skonteneryzować jej komponenty. Frontend i backend otrzymały własne pliki Dockerfile do budowy obrazu. Baza danych będzie uruchomiona w domyślnym kontenerze MySQL.

### Konfiguracja

Obrazy Dockera muszą zostać zbudowane przy pomocy instancji Dockera Minikube. Żeby to zrobić, należy zmienić kontekst terminala poleceniem `eval $(minikube docker-env)`:

![Zmiana kontekstu dockera](images/4.%20Zmiana%20kontekstu%20dockera.png)

Teraz terminal działa na Dockerze Minikube.

Budowanie obrazów:

![Budowanie obrazów dockera](images/5.%20Budowanie%20obrazów%20dockera.png)

Zbudowane obrazy:

![Zbudowane obrazy](images/6.%20Zbudowane%20obrazy.png)

Przełączenie kontekstu z powrotem na Docker urządzenia odbywa się przez wywołanie polecenia `eval $(minikube docker-env -u)`.

Posiadając obrazy komponentów aplikacji, można przystąpić do utworzenia i wdrożenia deploymentów, zdefiniowanych w plikach YAML. Zadaniem deploymentu jest zarządzanie zestawem podów.

Struktura plików:
* `apiVersion`: wersja API;
* `kind`: rodzaj komponentu (deployment, service, secret, etc.);
* `metadata`: metadane komponentu, t.j. jego nazwa lub przynależność do przestrzeni nazw;
* `spec`: lista specyfikacji, przechowująca całą konfigurację komponentu.

Lista specyfikacji:
* `replicas`: liczba replik podów, działających jednocześnie;
* `selector`: służy do łączenia komponentów ze sobą przez przypisy (`matchLabels`: *klucz-wartość* w deployment, *klucz-wartość* w innych komponentach);
* `template`: definiuje konfigurację i zachowanie podów t.j. ich nazwa, obraz Dockera, otwarte porty, zmienne środowiskowe, itp.

Wdrożenie następuje po wywołaniu polecenia `kubectl apply -f <plik.yaml>`:

![Aplikowanie deploymentów](images/7.%20Aplikowanie%20deploymentów.png)

Pliki YAML, odpowiedzialne za budowanie podów aplikacji, przechowują konfiguracje kilku komponentów (baza danych MySQL zawiera sekret, persistent volume claim, deployment i serwis). Dzięki temu jedno polecenie `apply` uruchamia wszystkie komponenty potrzebne do działania jednej części aplikacji.

Wszystkie komponenty są umieszczane w przestrzeni nazw `proton`, co umożliwia filtrowanie ich w poleceniach konfiguracyjnych. Wywołanie polecenia `kubectl get pods -n proton` wypisuje wszystkie pody aplikacji:

![Uruchomione pody](images/8.%20Uruchomione%20pody.png)

Pod przechowujący backend zrestartował się dwukrotnie przed poprawnym działaniem. Żeby znaleźć przyczynę, można przeczytać jego logi dzięki poleceniu `kubectl logs -n proton <nazwa poda> --previous`. Flaga `previous` wzkazuje przedostatni log. Użyta jest dlatego, że ostatni log dotyczy poprawnego uruchomienia poda:

![Logi poda z backendem](images/9.%20Logi%20poda%20z%20backendem.png)

Pod z backendem nie był w stanie nawiązać połączenia z bazą danych prawdopodobnie dlatego, że zakończył konfigurację szybciej od niej. Jego plik YAML zawiera dwa komponenty Kubernetesa w przeciwieństwie do pliku bazy danych, który posiada ich cztery, z czego jeden montuje bazę na urządzeniu lokalnym. Biorąc pod uwagę charakter struktury programu, zachowanie to nie jest alarmujące.

Status komponentów Kubernetesa można monitorować na zintegrowanym Dashboardzie, dostępnym pod poleceniem `minikube dashboard`:

![Dashboard](images/10.%20Dashboard.png)

Wszystkie komponenty działają poprawnie.

Ostatnim krokiem konfiguracji aplikacji jest port forwarding. Bez niego frontend aplikacji nie nawiąże połączenia z backendem, co uniemożliwi jej poprawne działanie:

![Konfiguracja port forwardingu](images/11.%20Konfiguracja%20port%20forwardingu.png)

Struktura klastra wygląda teraz następująco:

* Frontend pod: http://<cluster IP>:30080
* Backend pod: http://localhost:3000
* Database pod: http://localhost:3306 (niedostępny z przeglądarki)

Adres klastra Minikube można podejrzeć poleceniem `minikube ip`.

Sukces wdrożenia deploymentu można sprawdzić poleceniem `kubectl rollout status -n proton deployment/<nazwa deploymentu>`:

![Rollouty](images/18.%20Rollouty.png)

Wszystkie wdrożenia przebiegły pomyślnie.

### Testowanie aplikacji

Backend jest wyposażony w endpoint, przeznaczony do testowania łączności:

![Endpoint kontrolera](images/27.%20Endpoint%20kontrolera.png)

Kod funkcji serwisu:

![Kod serwisu](images/28.%20Kod%20serwisu.png)

Wejście pod adres backendu zwraca wiadomość "Hello World!":

![Test łączności backendu](images/12.%20Test%20łączności%20backendu.png)

Aplikacja jest dostępna pod adresem klastra:

![Aplikacja webowa](images/13.%20Aplikacja%20webowa.png)

Rejestracja nowego użytkownika:

![Rejestracja](images/14.%20Rejestracja.png)

Sukces rejestracji oznacza działające połączenie frontend-backend-database.

Tworzenie nowego posta:

![Tworzenie posta](images/15.%20Tworzenie%20posta.png)

Podgląd głównej strony aplikacji:

![Post na stronie](images/16.%20Post%20na%20stronie.png)

Instancja terminala utrzymująca port forwarding wykrywa żądania wysyłane do backendu:

![Obsługa requestów przez backend](images/17.%20Obsługa%20requestów%20przez%20backend.png)

Aplikacja działa poprawnie.

### Aplikacja z 4 replikami podów

Repliki podów służą jako ich backup. Stan podów jest ciągle zapisywany, więc jeżeli jeden zawiedzie, drugi wejdzie na jego miejsce. Rozwiązuje to problem złośliwych awarii, przerywających działanie programu, zmuszających do ponawiania całego procesu konfiguracji. Kubernetes automatycznie przełączy kontekst do innego poda i przywróci zdrowy stan wadliwemu.

Ponieważ pliki deploymentów są już skonfigurowane, wystarczy zmienić ilość replik podów w każdym z nich na 4.

Aplikowanie przebiega identycznie:

![Aplikowanie deploymentów](images/19.%20Aplikowanie%20deploymentów%20(4%20repliki).png)

Widać cztery instancje każdego poda, z wyjątkiem bazy danych:

![Urhomione pody](images/20.%20Uruchomione%20pody%20(4%20repliki).png)

Baza danych nie może zostać zreplikowana w ten sam sposób jak pozostałe komponenty, gdyż nie jest ona "bezstanowa" jak one. Należałoby skonfigurować deployment tak, żeby stworzył jedną bazę danych i odczytujące z niej repliki. Frontend i backend są łatwe do zreplikowania gdyż przetwarzają one tylko żądania.

Struktura klastra wygląda teraz następująco:
* Frontend deployment: 4 repliki
* Backend deployment: 4 repliki
* Database deployment: 1 replika

Statystyki te widać na dashboardzie:
* 3 deploymenty
* 9 podów
* 3 zestawy replik

![Dashboard](images/21.%20Dashboard%20(4%20repliki).png)

Każdy zestaw replik podlega jednemu serwisowi:

![Serwisy](images/22.%20Serwisy%20(4%20repliki).png)

Serwis jest odpowiedzialny za łączność między podami. Definiuje on typ połączenia i jego porty. W przypadku występowania replik, obsługuje on nadchodzące żądania automatycznie.

### Testowanie aplikacji dla 4 replik

Proces testu osiągalności backendu, rejestracji, logowania i tworzenia posta przebiega identycznie jak w przypadku braku dodatkowych podów:

![Test łączności backendu](images/23.%20Test%20łączności%20backendu%20(4%20repliki).png)

Strona główna przed rejestracją:

![Aplikacja webowa](images/24.%20Aplikacja%20webowa%20(4%20repliki).png)

Strona główna po zalogowaniu i utworzeniu posta:

![Post na stronie](images/25.%20Post%20na%20stronie%20(4%20repliki).png)

Requesty do backendu:

![Obsługa requestów przez backend](images/26.%20Obsługa%20requestów%20przez%20backend%20(4%20repliki).png)

## Podsumowanie

Kubernetes współpracuje z Dockerem i przenosi go na zdecydowanie większą skalę. Zajmuje się on dynamicznym tworzeniem infrastruktury klastrów i zarządzaniem nią. Kontenery są otoczone przez pody, połączone ze sobą dzięki serwisom. Kiedy jeden komponent zawiedzie, jest on automatycznie uruchamiany ponownie i przywracany do zdrowego stanu, podczas gdy na jego miejsce może płynnie trafić nowy, sprawnie maskując zajście jakiejkolwiek awarii, przyspieszając proces symulacji. Kubernetes jest idealnym narzędziem do skutecznego i realistycznego testowania rozbudowanych infrastruktur.