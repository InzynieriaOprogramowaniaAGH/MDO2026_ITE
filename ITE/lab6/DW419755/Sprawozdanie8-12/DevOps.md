LAB8:

Instalacja zarządcy Ansible:

Ten sam system opracyjny, nazwa ansible-target:

![][image1]

Zainstalowane tar, openssh, utowrzone hostname i nazwe użytkownika:

![][image2]

Łączenie z głównej maaszyny na ansible-target:

![][image3]

Inwentaryzacja:
Ustalenie nazwy komputerów:
Host:

![][image4]

Docelowa:

![][image5]

Weryfikacja łączności:

![][image6]

Plik inwentaryzacji:

![][image7]

Zapytanie o ping:

![][image8]

tasks.yaml:
![][image9]

Uruchamianie aplikacji redis:
Dockerfile:
![][image10]
Werfyfikowanie czy działa:
![][image11]
![][image12]

plik tasks.yaml:

![][image13]

deploy.yaml:

![][image14]

ansible-galaxy:

![][image15]

LAB9:

Zainstelowano fedora:
![][image16]

Stworzono plik odpowiedzi:
![][image17]
![][image18]

Umieszczono plik na serwerze:
![][image19]

Wzkazano instalatorowi odpoiwedni plik:
![][image20]

Status redis-custom-service:
![][image21]

Sprawdzenie czy działa:
![][image22]

LAB10:

Instalacja minikubctl:

![][image23]

![][image24]

Alias minikubctl:

![][image25]

Uruchomienie klastra:

![][image26]

Sprawdzanie czy działa:

![][image27]

![][image28]

Bezpieczne połączenie:

![][image29]

Zmiana deploy:
![][image30]

![][image31]

Aplikacja Redis została zbudowana w pipeline CI (kompilacja w mdo-builder, pakowanie do mdo-runtime) i uruchomiona jako kontener Docker. Kontener mdo-redis-demo na obrazie mdo-runtime:3 nasłuchuje na porcie 6379 wewnątrz kontenera (mapowanie host:16379). Testy redis-cli ping (PONG) oraz zapis/odczyt klucza potwierdzają poprawne działanie aplikacji w izolacji kontenera.

Kubernetes:
Uruchominie kontenera:

![][image32]

Sprawdznie czy działa:

![][image33]

![][image34]

Dashboard:

![][image35]

Port forwarding:

![][image36]

Z inngego terminala:

![][image37]

Wdrożenie:

![][image38]
![][image39]
![][image40]
![][image41]

Konsola:
Apply:
![][image42]

Cztery repliki:

![][image43]

Rollout:

![][image44]

![][image45]

ping-pong:

![][image46]

LAB11:

Rejestrowanie nowej wersji obrazu:

![][image47]

![][image48]

![][image49]

Tagowanie obrazu:

![][image50]

Sprawdzanie czy działa:

![][image51]

Tworzenie obrazu z błędem:

![][image52]

![][image53]

Tagowanie i sprawdzanie działania:

![][image54]

Pushowanie obrazu na Dockerhub:

![][image55]

Zmiany w pliku .yaml:
zwiększenie replik do 8:

![][image56]

![][image57]

Zmniejszenie replik do 1:

![][image58]

Zmniejsznie replik do 0:

![][image59]

Zwiększenie replik do 4:

![][image60]

Wprowadzenie nowego obrazu:

![][image61]

Wprowadzenie nowego obrazu z błędem:

![][image62]

Badanie obrazu z błędem:

![][image63]
![][image64]

Rollout oraz zastosowanie starszej wersji obrazu:

![][image65]

Sprawdzanie histori rolloutów:

![][image66]

Cofnięcie rolloutu:

![][image67]

Historia wdrożenia i problemy:
W trakcie testów każda modyfikacja pliku YAML i ponowne kubectl apply generowała nową rewizję w kubectl rollout history. Skalowanie replik było rejestrowane jako kolejne rewizje Deploymentu: przy replicas 0 Service tracił endpointy i usługa była niedostępna, lecz rollout formalnie się kończył. Po przywróceniu co najmniej 4 replik pody wracały do stanu Running. Zmiana obrazu na nowszą wersję oraz powrót do starszej przebiegały zgodnie ze strategią, natomiast wdrożenie obrazu wadliwego powodowało CrashLoopBackOff oraz zatrzymanie rolloutu.

Skrypt do sprawdzania czy wdrożenie się powiodło w 60 sekund:

![][image68]

Uruchomienie skryptu:

![][image69]

Skrpyt ujęty w pipeline:

![][image70]

Wersej wdrożeń:
canary:

![][image71]

![][image72]

![][image73]

![][image74]

![][image75]

Rolling:

![][image76]

![][image77]

Recreate:

![][image78]

![][image79]

Sprawdzanie stanów wdrożenia:

![][image80]

Różnice między wersjami wdrożeń:
Rolling Update: aktualizacja odbywa się stopniowo poprzez wymianę kolejnych replik, przy czym część instancji poprzedniej wersji pozostaje dostępna w trakcie wdrożenia, co minimalizuje przestoje usługi.

Recreate: przed uruchomieniem nowej wersji wszystkie repliki poprzedniej wersji są usuwane, a następnie tworzone są instancje nowej wersji; strategia ta powoduje krótkotrwałą niedostępność usługi, ale eliminuje równoległe działanie obu wersji w ramach jednego obiektu Deployment.

Canary: nowa wersja jest wdrażana równolegle ze stabilną w osobnych obiektach Deployment, a na instancje testowe kierowany jest ograniczony ruch produkcyjny, co umożliwia weryfikację poprawności wdrożenia przed pełnym przełączeniem całego obciążenia na nową wersję.

LAB12:

Logowanie do Azure:

![][image81]

![][image82]

Zmienne lokalne:

![][image83]

Tworzenie grupy:

![][image84]

Wdrożenie kontenera z Docker Hub:

![][image85]

Ten obraz nie działa, zmieniam na httpd:apline:

![][image86]

Wykazanie że działa:

![][image87]

Stan instancji:

![][image88]

Logi:

![][image89]

Dostęp HTTP:

![][image90]

Logi po dostępie HTTP (200 OK):

![][image91]

Zatrzymanie i usunięcie:

![][image92]

![][image93]

[image1]: image1.png
[image2]: image2.png
[image3]: image3.png
[image4]: image4.png
[image5]: image5.png
[image6]: image6.png
[image7]: image7.png
[image8]: image8.png
[image9]: image9.png
[image10]: image10.png
[image11]: image11.png
[image12]: image12.png
[image13]: image13.png
[image14]: image14.png
[image15]: image15.png
[image16]: image16.png
[image17]: image17.png
[image18]: image18.png
[image19]: image19.png
[image20]: image20.png
[image21]: image21.png
[image22]: image22.png
[image23]: image23.png
[image24]: image24.png
[image25]: image25.png
[image26]: image26.png
[image27]: image27.png
[image28]: image28.png
[image29]: image29.png
[image30]: image30.png
[image31]: image31.png
[image32]: image32.png
[image33]: image33.png
[image34]: image34.png
[image35]: image35.png
[image36]: image36.png
[image37]: image37.png
[image38]: image38.png
[image39]: image39.png
[image40]: image40.png
[image41]: image41.png
[image42]: image42.png
[image43]: image43.png
[image44]: image44.png
[image45]: image45.png
[image46]: image46.png
[image47]: image47.png
[image48]: image48.png
[image49]: image49.png
[image50]: image50.png
[image51]: image51.png
[image52]: image52.png
[image53]: image53.png
[image54]: image54.png
[image55]: image55.png
[image56]: image56.png
[image57]: image57.png
[image58]: image58.png
[image59]: image59.png
[image60]: image60.png
[image61]: image61.png
[image62]: image62.png
[image63]: image63.png
[image64]: image64.png
[image65]: image65.png
[image66]: image66.png
[image67]: image67.png
[image68]: image68.png
[image69]: image69.png
[image70]: image70.png
[image71]: image71.png
[image72]: image72.png
[image73]: image73.png
[image74]: image74.png
[image75]: image75.png
[image76]: image76.png
[image77]: image77.png
[image78]: image78.png
[image79]: image79.png
[image80]: image80.png
[image81]: image81.png
[image82]: image82.png
[image83]: image83.png
[image84]: image84.png
[image85]: image85.png
[image86]: image86.png
[image87]: image87.png
[image88]: image88.png
[image89]: image89.png
[image90]: image90.png
[image91]: image91.png
[image92]: image92.png
[image93]: image93.png
