
Uruchomiono obraz dockera, który eksponuje środowisko zagnieżdżone

ZDJECIE 1

Następnie przygotowano obraz blueocean na podstawie obrazu Jenkinsa, budując Dockerfile.jenkins, wykorzystany na poprzednich labolatoriach.

ZDJECIE2

Następnie go uruchomiłem

ZDJECIE 3

OPISZ ROZNICE "czym sie rozni blueocean od obrazu jenkinsa"

przy pomocy docker 
        exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

ZDCJECIE 4

wysweitliłem hasło do strony konfiguracyjnej jenkinsa, wpisalem jako hasło na stronie konfiguracyjnej jenkinsa.
Tam zainstalowałem sugerowane wtyczki. Po procesie instalacji stworzyłem pierwszego administratora.

ZDJECIED 5

Po zakończonej konfiguracji. Zająłem się logami aplikacji, dotychczas niewidocznymi poprzez uruchomienie w trybie detach. Dowiedziałem się, że są one przekierowywane w dockerze.

Przy pomocy polecenia

        nohup docker logs -f jenkins-blueocean >> jenkins_lab5.log 2>&1 &

Zadbałem by był one wypisywane na bieżąco do pliku.
Utworzyłem 2 projekty typu pipeline, pierwszy wyświetla uname, a drugi błąd jeżeli godzina jest niepatzysta. Zrealizowałęm to przy pomocy skryptu Groovy:

ZDJECIE 6

ZDJECIE 7




