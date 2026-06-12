1.	Uruchomienie środowiska zagniezdzonego

![alt text](image.png)
![alt text](image-1.png)

2. Przygotowanie obrazu blueocean

Czym różni się Jenkins od Blue Ocean?
Standardowy Jenkins: Posiada klasyczny interfejs graficzny, który jest funkcjonalny, ale bywa mało czytelny przy skomplikowanych procesach.
Blue Ocean: To nowoczesna nakładka graficzna zaprojektowana specjalnie dla Pipelineów. Ułatwia diagnostykę błędów.

Tresc pliku Dockerfile potrzebnego do stworzenia obrazu

![alt text](image-2.png)

zbudowanie obrazu: docker build -t myjenkins-blueocean 

![alt text](image-3.png)

3. Uruchomienie Blueocean

![alt text](image-4.png)

4. Zalogowanie i skonfigurowanie Jenkinsa

![alt text](image-5.png)

5. Utworzenie projektu **uname**\

![alt text](image-6.png)

![alt text](image-7.png)

sprawdzenie:

![alt text](image-8.png)

6. Utworzenie zadania sprawdzającego godzine

skrypt:
HOUR=$(date +%H)
echo "Aktualna godzina: $HOUR"

if [ $((HOUR % 2)) -ne 0 ]; then
  echo "BŁĄD: Godzina $HOUR jest nieparzysta!"
  exit 1
else
  echo "SUKCES: Godzina $HOUR jest parzysta."
  exit 0
fi

![alt text](image-9.png)

Działa poprawnie

7. Utwórz nowy obiekt typu pipeline

![alt text](image-10.png)

Sprawdzenie czy zadanie poprawnie klonuje repozytorium:

![alt text](image-11.png)

8. Poprawne skolonowanie z mojej gałęzi:

![alt text](image-13.png)

9. porówannie czasu

![alt text](image-12.png)

drugie zadanie znacznie szybciej się wykonuje