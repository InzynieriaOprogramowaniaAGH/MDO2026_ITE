# Sprawozdanie teoretyczne 5,6,7 – Jenkins Pipeline, CI/CD i izolacja etapów

## 1. Wprowadzenie do CI/CD i Jenkins

Współczesne procesy wytwarzania oprogramowania opierają się na automatyzacji budowania, testowania i wdrażania aplikacji. Podejście to określane jest jako **CI/CD (Continuous Integration / Continuous Delivery)**. Jego głównym celem jest skrócenie czasu dostarczania zmian oraz zwiększenie jakości kodu.

Jednym z najpopularniejszych narzędzi realizujących te założenia jest Jenkins — serwer automatyzacji umożliwiający definiowanie procesów jako tzw. pipeline’y.

Pipeline to sekwencja kroków (etapów), które są wykonywane automatycznie, np.:
- pobranie kodu,
- budowanie aplikacji,
- testowanie,
- wdrożenie,
- publikacja artefaktów.

---

## 2. Architektura Jenkinsa i Blue Ocean

Jenkins działa jako serwer, który wykonuje zadania w oparciu o:
- konfigurację jobów,
- pliki Jenkinsfile,
- wtyczki rozszerzające funkcjonalność.

Rozszerzeniem interfejsu użytkownika jest Blue Ocean — nowoczesna nakładka wizualna, która:
- prezentuje pipeline jako graf,
- ułatwia analizę błędów,
- poprawia czytelność procesu CI/CD.

---

## 3. Pipeline as Code

Kluczowym elementem laboratoriów jest podejście **Pipeline as Code**, w którym konfiguracja procesu CI/CD zapisana jest w pliku `Jenkinsfile`.

Cechy tego podejścia:
- wersjonowanie pipeline razem z kodem,
- powtarzalność wykonania,
- łatwa modyfikacja i audyt zmian.

Pipeline w Jenkinsie definiowany jest w języku **Groovy** i składa się z:
- `agent` – środowisko wykonania,
- `stages` – etapy,
- `steps` – polecenia.

---

## 4. Konteneryzacja i Docker

W laboratoriach wykorzystano Docker jako mechanizm izolacji środowiska.

Kontenery umożliwiają:
- uruchamianie aplikacji w identycznym środowisku,
- izolację zależności,
- łatwe przenoszenie między systemami.

W pipeline wykorzystuje się:
- obrazy buildowe,
- kontenery do testów i deployu.

---

## 5. Docker-in-Docker (DIND)

W celu zapewnienia izolacji wykorzystano podejście **Docker-in-Docker (DIND)**, polegające na uruchomieniu demona Dockera wewnątrz kontenera.

### Zalety:
- pełna izolacja środowiska CI,
- brak wpływu na hosta.

### Wady:
- większe zużycie zasobów,
- niższa wydajność.

Alternatywą jest korzystanie z demona Dockera hosta.

---

## 6. Lab 5 – Pipeline i izolacja etapów

W tym laboratorium skonfigurowano Jenkins oraz utworzono pierwszy pipeline.

### Etapy:
1. **Clone** – pobranie repozytorium,
2. **Checkout** – dostęp do plików (np. Dockerfile),
3. **Build** – budowanie obrazu Docker.

Kluczowym aspektem była izolacja etapów oraz automatyzacja procesu budowania.

---

## 7. Lab 6 – Kompletny pipeline CI/CD

Pipeline został rozszerzony o pełny proces CI/CD.

### Etapy:
- **Build** – kompilacja aplikacji (.NET),
- **Test** – uruchomienie testów jednostkowych,
- **Deploy** – uruchomienie kontenera,
- **Publish** – archiwizacja artefaktów.

### Testowanie

Do testów wykorzystano framework xUnit, który umożliwia automatyczne sprawdzanie poprawności działania aplikacji.

### Artefakty

Artefakt (np. `.tar.gz`) to wynik działania pipeline:
- zawiera skompilowaną aplikację,
- jest wersjonowany numerem builda,
- może być wdrażany w innych środowiskach.

---

## 8. Lab 7 – Izolacja etapów i ulepszenie pipeline

Pipeline został ulepszony poprzez:

### Czyszczenie workspace
Użycie `cleanWs()` zapewnia:
- brak pozostałości po poprzednich buildach,
- większą stabilność.

### Oddzielenie etapów build i test
Zastosowano osobne obrazy Docker:
- buildowy,
- testowy.

Zapewnia to lepszą izolację i spójność środowiska.

### Automatyczne sprzątanie
Sekcja `post` usuwa:
- kontenery,
- obrazy Docker.

---

## 9. Znaczenie etapów pipeline

| Etap | Znaczenie |
|------|----------|
| Clone | Pobranie kodu |
| Build | Kompilacja aplikacji |
| Test | Weryfikacja poprawności |
| Deploy | Uruchomienie aplikacji |
| Publish | Udostępnienie artefaktu |

Pipeline realizuje zasadę **fail fast** — błędy wykrywane są możliwie jak najwcześniej.

---

## 10. Wersjonowanie i powtarzalność

Zastosowano:
- wersjonowanie przez `BUILD_NUMBER`,
- stałe wersje obrazów (np. .NET 8.0).

Zapewnia to:
- identyfikowalność buildów,
- możliwość odtworzenia środowiska.

---

## 11. Podsumowanie

Laboratoria pokazują praktyczne zastosowanie:
- CI/CD,
- konteneryzacji,
- automatyzacji procesów.

### Wnioski:
- Jenkins umożliwia automatyzację procesu wytwarzania oprogramowania,
- Docker zapewnia izolację i powtarzalność,
- pipeline jako kod zwiększa kontrolę nad procesem,
- podział na etapy poprawia czytelność i niezawodność.