## 1. Przygotowanie: Utworzenie instancji Jenkins
Zgodnie z instrukcją uruchomiono środowisko składające się z dwóch kontenerów w dedykowanej sieci `jenkins`:
1. Kontener `jenkins-docker` oparty na obrazie `docker:dind`, udostępniający gniazdo Dockera.
2. Kontener `jenkins-blueocean` oparty na oficjalnym obrazie Jenkinsa. 

Po uruchomieniu środowiska, Jenkins został wstępnie skonfigurowany, a hasło administratora pobrano z logów kontenera.
![haslo](IMG/Zrzut%20ekranu%202026-04-10%20103553.png)
![logowanie](IMG/Zrzut%20ekranu%202026-04-10%20103603.png)
![jenkins](IMG/Zrzut%20ekranu%202026-04-10%20103629.png)
![jenkins2](IMG/Zrzut%20ekranu%202026-04-10%20104026.png)
---

## 2. Zadania wstępne: Konfiguracja i pierwsze uruchomienie

### 2.1. Zadanie wyświetlające `uname`
**Skrypt:**
```bash
uname -a
```

**Wynik:**
Zadanie zakończyło się statusem `SUCCESS`, zwracając informacje o jądrze systemu Linux.

![Wyjście konsoli - uname](IMG/Zrzut%20ekranu%202026-04-10%20105301.png)

### 2.2. Zadanie zwracające błąd, gdy godzina jest nieparzysta
**Skrypt:**
Aby uniknąć błędu interpretacji liczb z zerem wiodącym jako systemu ósemkowego (np. `08`), zastosowano flagę `%-H` w komendzie pobierającej czas.

```bash
GODZINA=$(date +%-H)
echo "Aktualna godzina: $GODZINA"

if [ $((GODZINA % 2)) -ne 0 ]; then
    echo "BŁĄD: Godzina $GODZINA jest nieparzysta!"
    exit 1
else
    echo "SUKCES: Godzina $GODZINA jest parzysta."
    exit 0
fi
```

![Wyjście konsoli - godzina](IMG/Zrzut%20ekranu%202026-04-10%20105659.png)

### 2.3. Zadanie pobierające obraz `ubuntu` (`docker pull`)

**Skrypt:**
```bash
docker pull ubuntu:latest
```
Obraz został pomyślnie pobrany do środowiska Dockera obsługującego Jenkinsa.

![Wyjście konsoli - docker pull](IMG/Zrzut%20ekranu%202026-04-10%20110939.png)

---

## 3. Zadanie główne: Obiekt typu Pipeline

### 3.1. Skrypt Pipeline
Skrypt realizuje dwa główne kroki: sklonowanie repozytorium przedmiotowego na osobistej gałęzi (`PK423390`) oraz zbudowanie obrazu Dockerowego na podstawie wcześniej przygotowanego pliku `Dockerfile`, który znajdował się w podkatalogu. W tym celu użyto bloku `dir()`.

```groovy
pipeline {
    agent any

    stages {
        stage('Sklonowanie repozytorium') {
            steps {
                git branch: 'PK423390', url: '[https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git)'
            }
        }
        
        stage('Zbudowanie Dockerfile') {
            steps {
                script {
                    echo "Wchodzę do katalogu z Dockerfile i buduję obraz..."
                    dir('grupa2/PK423390/L4') {
                        def customImage = docker.build("moj-builder:${env.BUILD_ID}")
                    }
                }
            }
        }
    }
}
```

### 3.2. Pierwsze uruchomienie
Podczas pierwszego uruchomienia Jenkins poprawnie nawiązał połączenie, pobrał repozytorium Git, wszedł do odpowiedniego podkatalogu i zainicjował budowanie obrazu. Docker pobrał wszystkie wymagane warstwy i wykonał instrukcje zawarte w pliku `Dockerfile`. Uruchomienie zakończyło się statusem `SUCCESS`.

![Wyjście konsoli - pierwsze uruchomienie potoku](IMG/Zrzut%20ekranu%202026-04-10%20113155.png)

### 3.3. Drugie uruchomienie i wnioski
Zgodnie z poleceniem, uruchomiono stworzony potok drugi raz.

**Wniosek:** Czas wykonania zadania podczas drugiego uruchomienia znacząco się skrócił. Analiza logów konsoli wykazała, że system wykorzystał pamięć podręczną Dockera (`CACHED`) dla poszczególnych warstw obrazu, pomijając całkowicie ponowne pobieranie bazowego obrazu Jenkinsa oraz instalację pakietów systemowych. Izolacja etapów w Jenkins Pipeline (osobny `stage` dla Git i osobny dla budowania) ułatwiła czytelność logów i pozwoliłaby na znacznie szybsze zlokalizowanie ewentualnych błędów.

![Wyjście konsoli - drugie uruchomienie potoku](IMG/Zrzut%20ekranu%202026-04-10%20121729.png)