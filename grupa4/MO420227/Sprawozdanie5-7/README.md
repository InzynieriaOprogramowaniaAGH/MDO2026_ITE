# Sprawozdanie z laboratoriów 5-7: Automatyzacja Procesów Wytwórczych Oprogramowania

## 1. Wstęp i koncepcja środowiska
Celem zrealizowanych prac było zaprojektowanie, implementacja i optymalizacja kompletnego procesu ciągłej integracji i ciągłego wdrażania (CI/CD). 

Środowisko uruchomieniowe zostało oparte na architekturze kontenerowej z wykorzystaniem serwera automatyzacji **Jenkins**. Zastosowano wzorzec **Docker-in-Docker (DinD)**, który polega na uruchomieniu serwera Jenkins wewnątrz kontenera z jednoczesnym udostępnieniem mu możliwości zarządzania demonem Dockera hosta. Architektura ta pozwala potokom Jenkinsa na natywne budowanie obrazów, uruchamianie testowych środowisk kontenerowych oraz publikację gotowych artefaktów bez konieczności instalowania zależności na serwerze bazowym.

## 2. Ewolucja zadań: Od projektów Freestyle do Pipelines

Proces wdrażania automatyzacji realizowany był etapowo, ilustrując ewolucję podejścia do konfiguracji zadań w systemach CI.

### 2.1. Zadania typu Freestyle
Początkowym etapem było wykorzystanie podstawowych zadań typu *Freestyle*. Służą one głównie do prostej automatyzacji skryptowej. Choć są one intuicyjne w konfiguracji poprzez GUI, nie skalują się dobrze w przypadku złożonych, wieloetapowych procesów i są trudne do wersjonowania.

### 2.2. Deklaratywne obiekty Pipeline
Odpowiedzią na ograniczenia projektów Freestyle są obiekty typu **Pipeline**. Pozwalają one na zdefiniowanie przepływu pracy jako sekwencji logicznych etapów. Zaimplementowano potok realizujący pełną ścieżkę wytwarzania oprogramowania:

1. **Clone (SCM):** Pobranie najnowszej wersji kodu źródłowego z repozytorium Git.
2. **Build:** Kompilacja kodu źródłowego z wykorzystaniem narzędzia Maven Wrapper.
3. **Test:** Wykonanie zautomatyzowanych testów jednostkowych i integracyjnych, których powodzenie jest warunkiem koniecznym do przejścia potoku do kolejnej fazy.
4. **Deploy:** Symulacja uruchomienia skompilowanej aplikacji w kontrolowanym środowisku.
5. **Publish:** Zarchiwizowanie wygenerowanych artefaktów binarnych w celu ich bezpiecznego przechowywania.

## 3. Optymalizacja procesu i mechanizm Docker Cache
Integracja potoków Jenkinsa z silnikiem Docker znacząco optymalizuje proces budowania. Podczas implementacji zaawansowanych pipeline'ów wykorzystano mechanizm **Docker Cache**. Silnik Dockera podczas kompilacji pliku `Dockerfile` analizuje kolejne warstwy obrazu. Jeśli instrukcje i pliki wejściowe dla danej warstwy nie uległy zmianie, Docker używa zapisanej wcześniej w pamięci podręcznej warstwy, zamiast budować ją od nowa. Mechanizm ten drastycznie redukuje czas potrzebny na kolejne uruchomienia potoku CI.

## 4. Wdrożenie paradygmatu Infrastructure as Code

Przełomowym etapem w projektowaniu systemów CI/CD jest rezygnacja z konfiguracji zadań z poziomu GUI na rzecz paradygmatu **Infrastructure as Code**. Wymaga to zdefiniowania całej logiki potoku w specjalnym pliku tekstowym – w tym przypadku `Jenkinsfile`.

### 4.1. Zalety podejścia Infrastructure as Code
Przeniesienie konfiguracji z wbudowanej bazy Jenkinsa bezpośrednio do repozytorium aplikacji przynosi szereg korzyści architektonicznych:
*   **Wersjonowanie potoku:** Kod potoku ewoluuje wraz z kodem aplikacji. Każda modyfikacja procesu wdrażania podlega  kontroli wersji w systemie Git.
*   **Code Review:** Zmiany w procesie budowania mogą być poddawane weryfikacji przez innych członków zespołu.
*   **Odtwarzalność:** W przypadku awarii serwera Jenkins, potok może zostać natychmiast odtworzony na innej instancji jedynie poprzez wskazanie repozytorium źródłowego.

### 4.2. Wielofazowe budowanie obrazów (Multi-stage Build)
W ostatecznej implementacji zdefiniowanej w `Jenkinsfile` wykorzystano zaawansowaną funkcję Dockera: **Multi-stage builds**. W ramach jednego pliku `Dockerfile` zdefiniowano obraz budujący (tzw. `builder`, posiadający m.in. środowisko JDK i Maven) oraz lekki obraz docelowy (zawierający jedynie środowisko uruchomieniowe JRE i gotowy plik `.jar`). 

Zastosowanie tego wzorca zaowocowało:
1. Zmniejszeniem rozmiaru finalnego obrazu kontenera.
2. Zwiększeniem bezpieczeństwa (brak narzędzi deweloperskich i dostępu do kodu źródłowego na środowisku produkcyjnym).
3. Automatyzacją ekstrakcji gotowego artefaktu z kontenera budującego do zasobów Jenkinsa.

### 4.3. Zarządzanie poświadczeniami i rejestr artefaktów
Ostatnim elementem kompletnego potoku CI/CD była publikacja przygotowanych i przetestowanych obrazów w rejestrze Docker Hub. Zastosowano mechanizm bezpiecznego zarządzania tajnymi danymi w Jenkinsie. Za pomocą bloku `withCredentials`, dane logowania do zewnętrznego rejestru były wstrzykiwane do potoku w sposób uniemożliwiający ich wyciek w logach konsoli.

## 5. Podsumowanie
Skonfigurowane środowisko demonstruje nowoczesne podejście do wytwarzania oprogramowania. Przejście od manualnie konfigurowanych, prostych zadań do zadeklarowanych w repozytorium potoków typu Pipeline, w ścisłej integracji z technologiami kontenerowymi, gwarantuje powtarzalność, skalowalność i wysokie bezpieczeństwo całego cyklu życia aplikacji oprogramowania.