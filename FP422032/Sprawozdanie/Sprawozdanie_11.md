# Sprawozdanie 11: Wdrażanie na zarządzalne kontenery - Kubernetes (2)
**Autor:** Filip Pyrek
**Indeks:** 422032

## 1. Przygotowanie nowych obrazów
Na początku musiałem przygotować trzy wersje obrazu z kalkulatorem. Ponieważ nie miałem bezpośredniego dostępu do kodu, stworzyłem nowe pliki `Dockerfile` i nadpisałem bazowy obraz:
* **v1:** to po prostu skopiowany, działający obraz bazowy.
* **v2:** wersja, w której za pomocą polecenia `sed` podmieniłem tekst na stronie, żeby było widać różnicę po aktualizacji.
* **error:** wersja zepsuta – w `Dockerfile` wpisałem komendę uruchamiającą nieistniejący plik, przez co kontener od razu wyrzuca błąd po starcie.

## 2. Skalowanie replik
W tej części edytowałem plik `kalkulator.yaml`, zmieniając wartość `replicas`, a następnie aplikowałem zmiany poleceniem `kubectl apply`. Obserwowałem, jak Kubernetes dynamicznie dodaje lub usuwa pody.

Sprawdziłem zachowanie klastra dla 8 replik:

![8 Replik](images/8Replik.png)

Dla 1 repliki:

![1 Replika](images/1Replika.png)

Oraz dla 0 replik (tak zwany "scale to zero" - pody zniknęły, ale sama konfiguracja wdrożenia została w systemie):

![0 Replik](images/0Replik.png)

Po testach przywróciłem standardowe 4 repliki.

## 3. Aktualizacje, błędy i cofanie zmian
Zmieniałem wersję obrazu (tagi) w pliku YAML i sprawdzałem, jak zachowuje się klaster podczas aktualizacji. 

Najpierw zaktualizowałem aplikację do nowej wersji V2:

![Zmiana na V2](images/ZmianaWersjiNaV2.png)

Następnie cofnąłem ją z powrotem do wersji V1:

![Zmiana na V1](images/ZmianaWersjiNaV1.png)

Potem celowo wdrożyłem wersję "error". Zauważyłem, że Kubernetes sam zorientował się, że nowe pody się psują (status `CrashLoopBackOff`) i automatycznie zatrzymał proces aktualizacji. Dzięki temu stare, działające pody wciąż obsługiwały ruch.

![Zmiana na Error](images/ZmianaWersjiNaError.png)

Sprawdziłem w konsoli zapisaną historię wdrożeń:

![Historia Kubernetesa](images/HistoriaKubernetesa.png)

Na koniec cofnąłem tę wadliwą aktualizację komendą `kubectl rollout undo`. Zepsute pody od razu zostały usunięte, a system wrócił do działającej wersji.

![Cofnięcie Zmian Undo](images/CofniecieZmianUndo.png)

## 4. Skrypt testujący czas wdrożenia
Napisałem krótki skrypt w Bashu, który sprawdzał, czy wdrożenie nowej wersji zdąży się wykonać w 60 sekund (wykorzystałem komendę `minikube kubectl -- rollout status`). Jeśli pody nie wstałyby w tym czasie (np. przez wadliwy obraz), skrypt zwróciłby błąd.

## 5. Różne strategie wdrażania
Na sam koniec przetestowałem, jak można inaczej aktualizować aplikację, dodając odpowiednie wpisy do pliku YAML:

**Strategia Recreate:** Zauważyłem, że Kubernetes najpierw całkowicie usunął wszystkie stare pody, a dopiero potem zaczął tworzyć nowe. Oznacza to niestety chwilową przerwę w działaniu aplikacji.

![Strategia Recreate](images/StrategiaRecreate.png)

**Zaawansowany Rolling Update:** Zmieniłem parametry w YAML tak, żeby Kubernetes mógł jednorazowo usuwać i tworzyć więcej podów na raz. Proces podmieniania wersji poszedł znacznie szybciej.

![Strategia Rolling Update](images/StrategiaRollingUpdate.png)

**Wdrożenie typu Canary (Kanarkowe):** Zamiast jednego, utworzyłem w pliku dwa osobne wdrożenia: stabilne (3 repliki) i nowe, kanarkowe (1 replika). Obie grupy podpiąłem pod ten sam Serwis za pomocą wspólnej etykiety `app: kalkulator`. W efekcie zauważyłem, że nowa, testowa wersja obsługiwała dokładnie 25% żądań, a reszta trafiała na wersję stabilną.

![Strategia Canary Deployment](images/StrategiaCanaryDeployment.png)

## Informacja o użyciu AI

1. **Ominięcie braku dostępu do kodu źródłowego przy tworzeniu wersji v2**:
   - **Zapytanie**: "Jak mogę stworzyć nową, zmodyfikowaną wersję obrazu z aplikacją (v2), jeśli nie mam dostępu do oryginalnego repozytorium na GitHubie, żeby edytować kod i przepuścić go przez pipeline?"
   - **Weryfikacja**: AI zaproponowało utworzenie krótkiego pliku `Dockerfile`, który jako bazę bierze stary obraz kalkulatora i używa wewnątrz niego komendy `sed`. Wyjaśniło, że `sed` pozwala przeszukać pliki HTML i w locie podmienić dany ciąg znaków na "v2". Po zapoznaniu się z tym poleceniem, zbudowałem z niego obraz. Rozwiązanie zadziałało poprawnie, pozwalając na stworzenie drugiej, zauważalnie innej wersji aplikacji z całkowitym pominięciem repozytorium.