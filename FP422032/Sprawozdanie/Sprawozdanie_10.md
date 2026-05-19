# Sprawozdanie 10: Wdrażanie na zarządzalne kontenery - Kubernetes (1)
**Autor:** Filip Pyrek
**Indeks:** 422032

## 1. Instalacja klastra Kubernetes i środowiska pracy
Zainstalowałem implementację klastra w oparciu o narzędzie Minikube. Instalację przeprowadziłem pobierając plik binarny protokołem HTTPS bezpośrednio z repozytorium Google. Przed uruchomieniem klastra przydzieliłem maszynie wirtualnej odpowiednie zasoby sprzętowe (2 vCPU i 4GB RAM), aby zmitygować ewentualne problemy z wydajnością. Skonfigurowałem również alias systemowy dla `kubectl`. Działanie środowiska zweryfikowałem uruchamiając Kubernetes Dashboard.

![Uruchomienie interfejsu graficznego Kubernetes Dashboard](images/Dashboard.png)

## 2. Ręczne wdrożenie aplikacji w klastrze
Jako aplikację wdrożeniową wybrałem artefakt z poprzednich laboratoriów – obraz `doretor/kalkulator:latest`. Podczas ręcznego wdrożenia za pomocą `kubectl run` wystąpił problem wyłączającego się natychmiast kontenera (status "Completed" oraz kolejne restarty Poda). Problem ten udało się zarzegnać, dodając do polecenia flagę `--command -- node server.js`, co zagwarantowało podtrzymanie pracy serwera aplikacji. 

![Weryfikacja statusu Poda po wdrożeniu manualnym](images/DzialajacyKontenerPoUruchomieniu.png)

![Widok stabilnie pracującego Poda w Dashboardzie](images/DzialajacyKontenerWKubernetes.png)

## 3. Eksponowanie funkcjonalności do środowiska zewnętrznego
Ponieważ klaster pracuje we własnej, odizolowanej podsieci, wyeksponowałem aplikację na zewnątrz wykorzystując mechanizm `port-forward`. Przekierowałem ruch z portu 8080 maszyny hosta bezpośrednio na port 3000 wewnątrz działającego Poda.

![Uruchomiony tunel poleceniem port-forward](images/DzialajacyPortForwarding.png)

Połączenie powiodło się, a interfejs kalkulatora został poprawnie obsłużony i wyświetlony w przeglądarce pod adresem localhost.

![Działająca aplikacja serwowana z wewnątrz kontenera na Kubernetes](images/OprogramowanieDzialajaceWKubernetes.png)

## 4. Przekucie wdrożenia manualnego w plik IaC (YAML)
Zastąpiłem ręczne wpisywanie poleceń plikiem konfiguracyjnym w formacie YAML. Plik został podzielony na zasób typu `Deployment` (zawierający definicję aplikacji) oraz `Service` (odpowiedzialny za rozkład ruchu i stały dostęp protów). Zgodnie z wytycznymi, w trakcie wdrożenia zdefiniowałem aż 4 niezależne repliki (pody) kalkulatora. 

![Badanie stanu wdrożenia poleceniem rollout status](images/StanWdrozeniaYAML.png)

Postęp wdrożenia monitorowałem komendą `kubectl rollout status`, a po jego zakończeniu przekierowałem porty tym razem bezpośrednio do Serwisu. Cztery działające niezależnie i równolegle repliki są widoczne w interfejsie graficznym klastra, co ostatecznie potwierdza stabilność środowiska.

![Cztery działające repliki aplikacji widoczne w Kubernetes Dashboard](images/DzialajacyYAMLWKubernetes.png)