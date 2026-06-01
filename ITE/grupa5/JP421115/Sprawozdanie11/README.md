# Sprawozdanie 11
Autor: Jan Pawelec

---

# Przygotowanie nowego obrazu
Jako pierwszą wersję wzięto build z poprzedniego laboratorium `nginx-0`. Skopiowano go i zmieniono w docelowym html nagłówek tak, że powstała wersja `nginx-1`. Do tego napisano zepsutą wersję `nginx-bad`, w której Dockerfile'u istnieje komenda odnosząca się do nieisntiejącego folderu. Wszelkie pliki załączono.

Obrazy zbudowano poleceniem `docker build -t nginx:v0 ./nginx-0` (i analogiczne inne wersje), a następnie załadowania na minikube poleceniem `minikube image load nginx:v0`. Zgodnie z poleceniem, zepsuty obraz jeszcze nie uległ uszkodzeniu. Komenda `CMD` dopiero podczas uruchomienia spowoduje awarię.
![alt text](1_efekt.png)

---

# Zmiany w deploymencie
Skopiowano plik .yaml z poprzedniego laboratorium. Ustawiono odpowiednie obrazy, zmieniono liczbę replik na 4. Następnie na 8, a potem na 1. Widoczne na poniższym zrzucie ekranu jest działanie narzędzia. Uruchamianie nowych 4 podów trwa w trakcie wyświetlania. W przypadki zmniejszenia widoczna jest operacja `Terminate` na nadmiarowych.
![alt text](2_841.png)

Po zmianie liczby replik na 0, działa tylko bazowy pod.
![alt text](2_aero.png)

Ponownie przeskalowano do 4. Uruchomiono na drugiej wersji obrazu (błąd z encodingiem zaskakujący).
![alt text](2_v2.png)

Następnie uruchomiono na starej wersji z poprzedniego laboratorium.
![alt text](2_vstare.png)

Następnie spróbowano uruchomić wersję zepsutą. Kubernetes po wywaleniu błędu nie kontynuwoał działań, więc stare pody dalej funkcjonują, co sprawia, że ostateczna aplikacja pozostała funkcjonalna.
![alt text](2_vbad.png)

Na koniec sprawdzono historię i przeprowadzono przywrócenie do poprzedniej wersji. Błąd wynika z polecenia `imagePullPolicy: Never`. Obraz został usunięty (zastąpiony nowym), więc przy cofnięciu się do wersji nie przeprowadził pull.
![alt text](2_rollout.png)

---

# Kontrola wdrożenia
W przykładowym jednym wdrożeniu widoczne jest zaprogramowane polecenie, mające na celu nieprawidłowe zakończenie operacji.
![alt text](3_hist.png)

Napisano skrypt `check-deployment.sh`, który kontroluje wdrożenie co 5 sekund. Wpierw przetestowano działający build.
![alt text](3_ok.png)

Następnie sprawdzono na nieprawidłowym.
![alt text](3_fail.png)

---

# Strategie wdrożenia
Utworzono nowy `strategy-recreate.yaml`, gdzie dodano stosowną linijkę. W ten sposób silnik nie korzysta ze starych podów tylko tworzy nowe.
![alt text](4_recreating.png)

Przy `strategy-rolling.yaml` bez zmiany wersji nic się nie dzieje, gdyż program nie wykrywa zmian.
![alt text](4_rolling1.png)

Z kolei po zmianie wersji na poprzednią, widoczna jest zmiana podów.
![alt text](4_rolling2.png)

Na koniec napisano `strategy-canary.yaml`. Polega on na mieszaniu buildów. Widoczny efekt jest na liście podów. Statystycznie rzecz biorąc, co czwarte wejście powoduje ujrzenie innej wersji.
![alt text](4_canary.png)