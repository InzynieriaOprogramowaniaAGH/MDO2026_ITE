# Zajęcia 11 – Kubernetes (2): Strategie wdrożeń
## Sprawozdanie

---

## CZĘŚĆ 1: Przygotowanie wersji obrazów

###  1:  wersja 5.2.1 (aktualna)

![alt text](image.png)

###  2:  wersja 5.2.2 (nowa wersja)

przepokowanie istniejącego obrazu przez commit:
![alt text](image-1.png)

###   3:  wersja "wadliwą" (5.2.3-broken)

![alt text](image-3.png)

###   4: Weryfikacja dostępnych obrazów

![alt text](image-2.png)

## CZĘŚĆ 2: Zmiany w deploymencie

### Bazowy plik deployment.yml (wersja startowa – 4 repliki)

![alt text](image-4.png)

---

###   5: Zwiększenie replik do 8

![alt text](image-5.png)
![alt text](image-6.png)

###   6: Zmniejszenie replik do 1

![alt text](image-7.png)

###   7: Zmniejszenie replik do 0

![alt text](image-8.png)

###   8: Przeskalowanie do 4 replik

![alt text](image-10.png)


---

###   9: Zastosowanie nowej wersji obrazu (5.2.2)

![alt text](image-11.png)

---

###   10: Powrót do starszej wersji (5.2.1)

![alt text](image-12.png)

---

###   11: Zastosowanie wadliwego obrazu (5.2.3-broken)

![alt text](image-13.png)
Deployment się "zawiesza" – stare pody dalej działają

![alt text](image-14.png)

Waiting for deployment... (nie kończy się)

---

## CZĘŚĆ 3: Historia i cofanie wdrożeń

###   12: Historia wdrożeń

![alt text](image-15.png)

![alt text](image-16.png)

![alt text](image-17.png)


Aby historia miała opisowe nazwy, można dodać adnotację przy apply:

![alt text](image-18.png)

###   13: Cofnięcie wdrożenia (undo)

![alt text](image-19.png)
![alt text](image-20.png)

---

## CZĘŚĆ 4: Skrypt weryfikujący wdrożenie

###   14:  skrypt verify-deployment.sh

![alt text](image-21.png)


## CZĘŚĆ 5: Strategie wdrożeń

###   15: Strategia Recreate


Zatrzymuje WSZYSTKIE stare pody przed uruchomieniem nowych. Powoduje chwilową niedostępność.

![alt text](image-22.png)

wszystkie pody zatrzymują się naraz, potem nowe startują

---

###   16: Strategia Rolling Update (z parametrami)

Aktualizuje pody stopniowo. Zawsze część podów jest dostępna.

![alt text](image-23.png)

![alt text](image-24.png)

---

###   17: Strategia Canary Deployment

![alt text](image-25.png)
![alt text](image-27.png)
![alt text](image-26.png)

---

## CZĘŚĆ 6: Porównanie strategii

| Strategia | Downtime | Ryzyko | Rollback | Kiedy używać |
|-----------|---------|--------|----------|--------------|
| **Recreate** | TAK (chwilowy) | Wysokie | Szybki | Środowiska testowe, brak wymogów dostępności |
| **RollingUpdate** | NIE | Średnie | Automatyczny | Produkcja, stopniowa aktualizacja |
| **Canary** | NIE | Niskie | Usuń canary deployment | Testowanie nowej wersji na części ruchu |


### Obserwacje

**Recreate:** Podczas aktualizacji z 5.2.1 na 5.2.2 wszystkie 4 pody zatrzymały się jednocześnie, przez ~10 sekund aplikacja była niedostępna, następnie uruchomiono 4 nowe pody z wersją 5.2.2.

**Rolling Update:** Aktualizacja przebiegła stopniowo – najpierw zatrzymano 2 pody (maxUnavailable=2), uruchomiono 2 nowe z 5.2.2, potem kolejne 2. Aplikacja była cały czas dostępna.

**Canary:** Ruch był rozłożony 75% na wersję stabilną (5.2.1) i 25% na canary (5.2.2). Po potwierdzeniu że 5.2.2 działa poprawnie – usunięto canary deployment i przeskalowano stable do 4 replik z nową wersją.