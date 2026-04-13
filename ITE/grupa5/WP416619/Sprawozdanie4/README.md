# Sprawozdanie 4 - Dodatkowa terminologia w konteneryzacji, instancja Jenkins

**Student:** Wilhelm Pasterz

**Indeks:** 416619

**Kierunek:** ITE

**Grupa: 5** 

## 1. Zachowywanie stanu między kontenerami

### Kreacja woluminow 

![](1.png)

### Klonowanie repo na wolumin 

![](2.png)

**Opis wykonania:**
Użyto komendy:
`docker run --rm -v vol_in:/target alpine/git clone <URL_REPO> .`
1. **Izolacja:** Wykorzystano gotowy obraz `alpine/git`, co wyeliminowało potrzebę instalacji Gita na hoście lub w docelowym obrazie budującym.
2. **Automatyzacja:** Dzięki fladze `--rm`, kontener po sklonowaniu kodu na wolumin został automatycznie usunięty, nie pozostawiając śmieci w systemie.
3. **Punkt montowania:** Wolumin `vol_in` zamontowano tymczasowo jako `/target`, gdzie Git bezpośrednio zapisał strukturę plików.

**Dlaczego ta metoda?**
* **Czystość środowiska:** Obraz budujący pozostaje lekki (brak `git` i jego zależności).
* **Bezpieczeństwo:** Nie manipulujemy bezpośrednio w katalogach systemowych Dockera.
* **Przenośność:** Rozwiązanie jest niezależne od plików na hoście – zadziała identycznie na każdym systemie z Dockerem.

### Budowanie projektu wewnątrz kontenera z wykorzystaniem woluminów

![](3.png)

![](4.png)

![](5.png)

### Weryfikacja zawartości woluminu

![](6.png)


**Zamiast ręcznego klonowania na woluminy, można instrukcji RUN --mount w Dockerfile. Pozwala ona na tymczasowe zamontowanie zewnętrznego zasobu na etap budowania obrazu. Dzięki temu pliki źródłowe nie stają się częścią ostatecznych warstw obrazu, co zmniejsza jego rozmiar i zwiększa bezpieczeństwo.**


---

## 2. Eksponowanie portu i łączność między kontenerami

### Uruchomienie dwóch kontenerów

![](7.png)

### Połączenie z drugiego kontenera

![](8.png)

### Ponowienie kroku przy pomocy dedykowanej sieci mostkowej

![](9.png)

### Połączenie się spoza kontenera

![](10.png)

![](11.png)


---

## 3. Usługi i CI/CD (SSHD & Jenkins)

### Uruchomienie kontener Ubuntu i zainstalowanie SSH:

![](12.png)

### Wewnątrz kontenera:

![](13.png)

![](14.png)

### Uruchomienie kontenera DIND

![](15.png)

### Uruchomienie serwera Jenkins

![](16.png)

### Sprawdzenie działania

![](17.png)

![](18.png)

![](19.png)

![](20.png)



