# Sprawozdanie - Laboratorium 12

**Piotr Walczak 419456**

## 1. Przygotowanie niezawodnego kontenera z usługą HTTP

Aby zminimalizować ryzyko problemów z bindowaniem portów zastrzeżonych w środowisku chmurowym, jako aplikację wybrano ekstremalnie lekki, wbudowany serwer HTTP języka Python (`python:3.9-alpine`), nasłuchujący na bezpiecznym porcie `8080`. 
Przygotowano plik `Dockerfile` serwujący statyczną stronę `index.html`. Obraz przebudowano i wypchnięto na osobiste konto w usłudze Docker Hub jako `piti83/azure-lab12:latest`.

![](sprawozdanie-ss/l12_1.png)

## 2. Inicjalizacja infrastruktury i omijanie limitów studenckich

W środowisku Azure Cloud Shell (Bash) przystąpiono do wdrożenia. Ze względu na restrykcyjne polityki Azure dla kont studenckich (powodujące błędy braku dostępnych zasobów w regionach takich jak Europa Zachodnia), przed wdrożeniem zidentyfikowano dostępny region: `norwayeast`. Następnie utworzono w nim Grupę Zasobów (Resource Group) o nazwie `Lab12_PW419456`.

![](sprawozdanie-ss/l12_2.png)

## 3. Deployment kontenera do Azure Container Instances (ACI)

Wdrożenie kontenera zrealizowano komendą `az container create`, wskazując obraz z Docker Huba. Zdefiniowano publiczny port `8080` oraz unikalną etykietę DNS (`pw419456-lab12-app`). Zgodnie z założeniami laboratorium, usługa ACI samoczynnie pobrała obraz z zewnętrznego rejestru bez konieczności konfiguracji prywatnego Azure Container Registry. Proces Provisioningu zakończył się sukcesem.

![](sprawozdanie-ss/l12_3.png)

## 4. Weryfikacja usługi HTTP i logi kontenera

Wylistowano parametry zasobu i pobrano wygenerowany w pełni kwalifikowany adres domenowy (FQDN). Następnie wykazano działanie usługi sieciowej łącząc się do niej poprzez narzędzie `curl` – serwer poprawnie zwrócił przygotowaną treść HTTP. 
Wykonano również komendę `az container logs`, która zrzuciła na ekran logi z samego kontenera, rejestrujące ruch w postaci zapytania GET.

![](sprawozdanie-ss/l12_4.png)

## 5. Sprzątanie środowiska

W celu pozstrzymania bezcelowego zużycia kredytów w subskrypcji Microsoft Azure, całkowicie usunięto utworzoną Grupę Zasobów wraz z jej całą zawartością (w tym działającym kontenerem), stosując komendę `az group delete`.

![](sprawozdanie-ss/l12_5.png)