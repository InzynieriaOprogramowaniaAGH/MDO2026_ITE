## Sprawozdanie

### Wdrożenia z liczbą replik 8, 1, 0 i ponownie 4:

![](1.png)

### Rollout history i undo:

![](2.png)

Polecenie rollout undo przywróciło wcześniejszą rewizję Deploymentu. Rewizja ta zawierała błędny adres obrazu localhost:5000/mf419850-web:latest. W środowisku Minikube adres localhost odnosił się do wnętrza noda Kubernetes, a nie do hosta Ubuntu, na którym działał lokalny rejestr Docker. W efekcie kubelet nie mógł pobrać obrazu i pody weszły w stan ImagePullBackOff. Problem rozwiązano przez ustawienie poprawnego obrazu z adresem rejestru 10.0.2.3:5000/mf419850-web:v1.

![](3.png)
![](4.png)

### aktualizacja wdrożenia do drugiej wersji obrazu aplikacji:

![](5.png)

### Weryfikacja działania drugiej wersji:

![](6.png)

### Próba wdrożenia wadliwego obrazu:

![](8.png)

### Konfiguracja wdrożenia ze strategią recreate:

![](9.1.png)

### Usuwanie wszystkich działających podów poprzedniej wersji aplikacji. Prez chwilę po zakończeniu procesu następuje niedostępność usługi.

![](9,2.png)

### Utworzenie nowych podów:

![](9.3.png)

### Konfiguracja wdrożenia ze strategią Rolling Update:

![](10.1.png)

### Nowe pody są tworzone podczas usuwania starych:

![](10.2.png)

### Działanie wdrożenia canary, działająca równolegle z głównym wdrożeniem, dodaje doadatkowy pod.

![](11.1.png)

### Konfiguracja wdrożenia canary:

![](11.2.png)

### Skrypt zweryfikował wykonanie wdrożenia w mniej niż 60 sekund.

![](12.png)