Sforkowane repozytorium redis:

![alt text](<image1.png>)

Podpięcie się do upstreama i stworzenie brancha ino_dev:

![alt text](<image2.png>)

Usuwanie starych workflow:

![alt text](<image4.png>)

Własna akcja:

![alt text](<image7.png>)

Triggerowanie akcji:

![alt text](<image5.png>)

Plik definiuje workflow CI/CD w GitHub Actions o nazwie ino_dev build, który automatycznie uruchamia się przy każdym pushu na gałąź ino_dev. Pipeline działa na runnerze Ubuntu, instaluje wymagane pakiety do kompilacji, a następnie buduje Redis poleceniem make. Po zakończeniu kompilacji wykonywany jest podstawowy test poprawności - sprawdzane są wersje skompilowanych binariów redis-server i redis-cli. Gotowe pliki wykonywalne są pakowane do archiwum redis-build.tar.gz i publikowane jako artefakt GitHub Actions, dostępny przez 7 dni. Cały proces ma ustawiony limit czasu na 30 minut.

Sprawdzenie czy akcja się wykonała:

![alt text](<image6.png>)

Link do runa:
https://github.com/DawidWy/redis/actions/runs/27191923797
