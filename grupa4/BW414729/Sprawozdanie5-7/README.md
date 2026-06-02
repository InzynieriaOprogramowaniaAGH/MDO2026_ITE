# Sprawozdanie zbiorcze z laboratoriów 05–07

## 1. Orkiestracja CI/CD – Jenkins i izolacja etapów

Celem pierwszego etapu było przeniesienie manualnych procesów budowania kontenerów do w pełni zautomatyzowanego środowiska Jenkins. Kluczowym wyzwaniem była poprawna konfiguracja wtyczek oraz zapewnienie komunikacji pomiędzy kontenerem Jenkinsa a demonem Dockera (architektura DinD – Docker in Docker).

### Konfiguracja i rozwiązywanie problemów

#### Aktualizacja środowiska

Podczas inicjalizacji środowiska wykryto problemy związane z kompatybilnością wtyczek. Problem rozwiązano poprzez:

- aktualizację obrazu Jenkinsa do najnowszej wersji LTS,
- wykonanie pełnej aktualizacji menedżera wtyczek przed konfiguracją zadań.

#### Dostęp do Dockera

Aby umożliwić Jenkinsowi wykonywanie komend `docker build` oraz `docker pull`, wdrożono konfigurację opartą o `docker-compose.yml`, która:

- montuje gniazdo Dockera,
- lub komunikuje się z pomocniczym kontenerem DinD.

Pozwoliło to wyeliminować problem braku klienta Dockera wewnątrz agenta Jenkins.

### Zadania weryfikacyjne

#### Odczyt parametrów systemowych

Poprawność działania agenta została zweryfikowana przy użyciu polecenia:

```bash
uname
```

#### Logika warunkowa – sprawdzanie godziny

Przygotowano skrypt sprawdzający parzystość aktualnej godziny.

W celu uniknięcia rozbieżności czasowych pomiędzy kontenerem a środowiskiem lokalnym zastosowano konfigurację:

```bash
TZ="Europe/Warsaw"
```

#### Integracja z Docker Hub

Wykonano poprawne pobranie obrazu:

```bash
docker pull ubuntu:latest
```

bezpośrednio z poziomu zadania Jenkins, co potwierdziło prawidłową komunikację z rejestrem Docker Hub.

---

## 2. Deklaratywne potoki budowania (Jenkins Pipeline)

Zrezygnowano z prostych zadań typu **Freestyle** na rzecz deklaratywnych potoków **Pipeline**. Podejście to umożliwia opisanie całego procesu życia aplikacji:

```text
Build → Test → Deploy → Publish
```

w formie kodu (`Pipeline as Code`), który może być przechowywany bezpośrednio w repozytorium projektu.

### Najważniejsze założenia

#### Mechanizm cache

Podczas kolejnych uruchomień pipeline'u zaobserwowano znaczące skrócenie czasu budowania dzięki:

- wykorzystaniu mechanizmu Docker Cache,
- inkrementalnej aktualizacji repozytorium Git.

#### Izolacja środowisk

Każdy etap procesu (`Build`, `Test`) wykonywany był w osobnym kontenerze, co zapewniło:

- czyste środowisko pracy,
- powtarzalność wyników,
- brak wpływu poprzednich buildów na aktualny proces.

---

## 3. Ścieżka krytyczna CI/CD dla projektu yt-dlp

Jako aplikację wdrażaną w rurociągu CI/CD wybrano narzędzie `yt-dlp` (licencja *The Unlicense*).

Proces został zaprojektowany w taki sposób, aby:

- minimalizować rozmiar końcowego artefaktu,
- zwiększać bezpieczeństwo środowiska uruchomieniowego,
- oddzielić etap budowania od etapu uruchamiania aplikacji.

### Etapy rurociągu (`Jenkinsfile`)

#### Clean Workspace

Każdy build rozpoczynał się od:

- wyczyszczenia przestrzeni roboczej,
- usunięcia nieużywanych obrazów przy pomocy:

```bash
docker system prune
```

Zapewniało to pełną niezależność kolejnych uruchomień pipeline'u.

#### Build (BLDR)

Do kompilacji binarnej wersji aplikacji wykorzystano `Dockerfile.build`.

Środowisko buildowe zawierało komplet zależności developerskich, między innymi:

- `make`,
- `zip`,
- `pandoc`.

#### Test

Testy jednostkowe `pytest` uruchamiano w osobnym kontenerze.

Wykorzystano tryb:

```bash
pytest -m "not download"
```

co pozwoliło przeprowadzać testy offline — istotne z punktu widzenia stabilności środowisk CI/CD bez gwarantowanego dostępu do zewnętrznych serwisów wideo.

#### Deploy (Smoke Test)

Przeprowadzono analizę zasadności używania kontenera buildowego jako środowiska runtime.

Stwierdzono, że takie rozwiązanie jest nieefektywne, ponieważ obraz buildowy:

- posiada zbędne zależności,
- zawiera kod źródłowy,
- zwiększa powierzchnię potencjalnego ataku (*Attack Surface*).

W związku z tym zastosowano następujące rozwiązanie:

1. wyodrębniono binarkę `yt-dlp-bin` z obrazu buildera,
2. utworzono finalny obraz runtime oparty o:

```text
python:3.10-slim
```

3. zweryfikowano poprawność działania aplikacji przy użyciu:

```bash
yt-dlp --version
```

---

## 4. Publikacja i „Definition of Done”

Proces uznawano za zakończony sukcesem w momencie wygenerowania gotowego do wdrożenia artefaktu (*deployable artifact*).

### Publikacja artefaktów

Wybrano publikację w postaci pliku binarnego archiwizowanego w Jenkinsie przy pomocy:

```groovy
archiveArtifacts
```

Decyzja ta wynikała z faktu, że `yt-dlp` jest narzędziem CLI, a użytkownik końcowy nie zawsze posiada środowisko Docker.

### Wersjonowanie

Zastosowano mechanizm **Fingerprinting**, umożliwiający jednoznaczne powiązanie artefaktu z:

- konkretnym commitem GitHub,
- numerem zadania Jenkins.

### Ostateczna weryfikacja

Pipeline wielokrotnie przechodził pełny proces budowania i publikacji, każdorazowo generując poprawny oraz w pełni wyizolowany artefakt binarny.

---

## 5. Podsumowanie i wnioski

Wdrożenie deklaratywnego pipeline'u Jenkins umożliwiło pełną automatyzację procesu dostarczania oprogramowania.

Najważniejszym wnioskiem wynikającym z realizacji projektu `yt-dlp` była konieczność wyraźnej separacji:

- środowiska budowania,
- środowiska uruchomieniowego.

Zastosowanie osobnych plików Dockerfile dla etapów `build` oraz `runtime` pozwoliło:

- zmniejszyć rozmiar końcowego obrazu,
- ograniczyć liczbę zbędnych zależności,
- zwiększyć poziom bezpieczeństwa środowiska uruchomieniowego.

Podejście to realizuje zasadę:

> **Attack Surface Reduction** — minimalizacji powierzchni potencjalnego ataku.

---

## Załączniki

Pliki:

- `Jenkinsfile`
- `Dockerfile.build`
- `Dockerfile.test`
- `Dockerfile` (runtime)

znajdują się w katalogu:

```text
grupa4/BW414729/Sprawozdanie7/
```

w repozytorium projektu.
