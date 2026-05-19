Instalacja minikubctl:

![alt text](image.png)

![alt text](image-1.png)

Alias minikubctl:

![alt text](image-2.png)

Uruchomienie klastra:

![alt text](image-3.png)

Sprawdzanie czy działa:

![alt text](image-4.png)

![alt text](image-5.png)

Bezpieczne połączenie:

![alt text](image-6.png)

Zmiana deploy:
![alt text](image-7.png)

![alt text](image-22.png)

Aplikacja Redis została zbudowana w pipeline CI (kompilacja w mdo-builder, pakowanie do mdo-runtime) i uruchomiona jako kontener Docker. Kontener mdo-redis-demo na obrazie mdo-runtime:3 nasłuchuje na porcie 6379 wewnątrz kontenera (mapowanie host:16379). Testy redis-cli ping (PONG) oraz zapis/odczyt klucza potwierdzają poprawne działanie aplikacji w izolacji kontenera.

Kubernetes:
Uruchominie kontenera:

![alt text](image-8.png)

Sprawdznie czy działa:

![alt text](image-9.png)

![alt text](image-10.png)

Dashboard:

![alt text](image-11.png)

Port forwarding:

![alt text](image-12.png)

Z inngego terminala:

![alt text](image-13.png)

Wdrożenie:

![alt text](image-14.png)
![alt text](image-15.png)
![alt text](image-16.png)
![alt text](image-17.png)

Konsola:
Apply:
![alt text](image-18.png)

Cztery repliki:

![alt text](image-19.png)

Rollout:

![alt text](image-20.png)

![alt text](image-23.png)

ping-pong:

![alt text](image-21.png)