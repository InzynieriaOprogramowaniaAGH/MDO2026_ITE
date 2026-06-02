# Sprawozdanie zbiorcze - zajęcia 05-07

**Autor:** MN420239 · **Grupa:** 4

---

## Zajęcia 05 - Jenkins, Docker i pierwszy pipeline

W ramach zajęć przygotowano kompletne środowisko **Jenkins** uruchomione w kontenerach Docker. Utworzono dedykowaną sieć `jenkins`, następnie uruchomiono kontener **Docker-in-Docker (DIND)**, który zapewniał Jenkinsowi możliwość wykonywania operacji na obrazach i kontenerach. Przygotowano również własny obraz Jenkins oparty na `jenkins/jenkins:lts`, rozszerzony o potrzebne wtyczki, w tym interfejs **Blue Ocean**.

Po uruchomieniu instancji Jenkins przeprowadzono konfigurację początkową: pobrano hasło administratora, utworzono użytkownika oraz zainstalowano sugerowane pluginy. W pierwszej części ćwiczenia wykonano kilka prostych zadań testowych, takich jak wyświetlenie informacji o systemie, sprawdzenie warunku zależnego od godziny oraz pobranie przykładowego obrazu Docker. Pozwoliło to potwierdzić poprawne działanie Jenkinsa oraz komunikację z warstwą kontenerową.

W drugiej części przygotowano pierwszy projekt typu **Pipeline**, obejmujący klonowanie repozytorium, przejście na właściwą gałąź, odnalezienie pliku `Dockerfile`, zbudowanie obrazu Docker oraz uruchomienie kontenera. Pipeline był uruchamiany wielokrotnie, co pozwoliło zweryfikować jego powtarzalność. Ćwiczenie pokazało, że połączenie Jenkins i Docker umożliwia budowanie izolowanych, automatycznych procesów CI.

---

## Zajęcia 06 - projekt i implementacja pełnego potoku CI/CD

Na kolejnych zajęciach przygotowano pełny potok **CI/CD** dla aplikacji frontendowej **Next.js** z repozytorium `aqi-ml-prediction-krakow-frontend`. Pipeline został zapisany w repozytorium jako **Declarative Pipeline** w pliku `Jenkinsfile`, dzięki czemu konfiguracja procesu budowania stała się częścią kodu projektu.

Ścieżka krytyczna procesu obejmowała etapy: `Clone -> Build -> Test -> Build Image -> Deploy -> Smoke Test -> Publish`. Budowanie aplikacji realizowano w kontenerze `node:20-alpine`, co gwarantowało powtarzalne środowisko uruchomieniowe. Następnie tworzono docelowy obraz Docker z aplikacją, uruchamianą przy pomocy `next start`, a więc jako serwer **Node.js**, a nie jako statyczny zestaw plików.

W pipeline uwzględniono również archiwizację logów builda, wersjonowanie artefaktu na podstawie numeru buildu i skrótu commita oraz publikację obrazu do **Docker Hub** pod nazwą `mrmacarthur/aqi-frontend`. Dzięki temu uzyskano artefakt, który można jednoznacznie powiązać z wersją kodu i wykorzystać poza środowiskiem Jenkins. Całość była zgodna z przygotowanym wcześniej diagramem UML i spełniała wymagania listy kontrolnej dla dojrzałego pipeline'u CI/CD.

---

## Zajęcia 07 - weryfikacja artefaktu i przygotowanie środowiska Ansible

Ostatni etap koncentrował się na sprawdzeniu, czy wytworzony artefakt jest rzeczywiście gotowy do wdrożenia. W tym celu opublikowany obraz Docker został pobrany i uruchomiony lokalnie poleceniem `docker run -p 3000:3000 mrmacarthur/aqi-frontend:latest`. Po uruchomieniu aplikacja była dostępna pod adresem `http://localhost:3000`, co potwierdziło, że obraz działa poprawnie także poza środowiskiem Jenkins.

Dodatkowo w aplikacji przygotowano endpoint kontrolny `/api/health`, zwracający odpowiedź JSON `{"status":"ok"}`. Wywołanie go przy pomocy `curl` stanowiło prosty **smoke test**, potwierdzający poprawną budowę aplikacji, poprawny start kontenera, działanie serwera Next.js oraz prawidłową odpowiedź endpointu API. Taka weryfikacja odpowiada idei **Definition of Done**: pipeline nie kończy się jedynie stworzeniem obrazu, ale także potwierdzeniem, że artefakt jest wdrażalny.

W dalszej części przygotowano środowisko pod automatyzację wdrożeń z użyciem **Ansible**. Zamiast pełnej maszyny wirtualnej utworzono lekki host docelowy w postaci kontenera Docker `ansible-target`, wyposażonego w system Linux, serwer `sshd`, użytkownika `ansible` oraz podstawowe narzędzia administracyjne. Skonfigurowano wymianę kluczy SSH, dzięki czemu logowanie do hosta docelowego mogło odbywać się bez hasła.

Na maszynie głównej utworzono plik `hosts` z definicją środowiska docelowego, a następnie wykonano test `ansible all -i hosts -m ping`. Pozytywny wynik potwierdził poprawne działanie komunikacji SSH oraz gotowość środowiska do zdalnego wykonywania poleceń. Tym samym projekt został rozszerzony z warstwy **CI** o praktyczne przygotowanie pod **CD**, czyli automatyczne i powtarzalne wdrażanie aplikacji.