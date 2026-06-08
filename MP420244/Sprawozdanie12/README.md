# Azure

Laboratoria poświęcone były tworzeniem grupy zasobów i kontenera w serwisie Microsoft Azure.

## Konfiguracja

Tworzenie grupy zasobów:

`az group create`
![Utworzenie grupy zasobów](images/1.%20Utworzenie%20grupy%20zasobów.png)

Dobór odpowiedniej lokalizacji jest kluczowy podczas konfiguracji środowiska. Nie każda lokalizacja jest obsługiwana przez dostępne kredyty. Wystarczającą dostępnością wykazało się `germanywestcentral`.

W grupie zasobów stworzono kontener `nginx`:

`az container create`
![Utworzenie kontenera nginx](images/2.%20Utworzenie%20kontenera%20nginx.png)

Wymagane jest podanie systemu operacyjnego i ilości zasobów `cpu` i `memory`. Należy też zadbać o to, żeby etykieta DNS miała globalnie unikalną nazwę, inaczej proces tworzenia kontenera zakończy się przez `Internal Server Error`.

Na liście kontenerów utworzonej grupy znajduje się wcześniej skonfigurowany kontener:

`az container show`
![Lista kontenerów](images/3.%20Lista%20kontenerów.png)

Logi kontenera:

`az container logs`
![Logi kontenera](images/4.%20Logi%20kontenera.png)

## Dostęp do kontenera

Poleceniem `az container show` można podejrzeć *Fully Qualified Domain Name* kontenera:

`az container show + fqdn`
![Nazwa domeny kontenera](images/5.%20Nazwa%20domeny%20kontenera.png)

Wchodząc pod wypisaną domenę, osiąga się wnętrze kontenera:

`http://<fqdn>`
![Nginx w domenie](images/6.%20Nginx%20w%20domenie.png)

Kontener ma również swój adres IP:

`az container show + ip`
![Adres kontenera](images/7.%20Adres%20kontenera.png)

Kontener jest dostępny w przeglądarce pod wypisanym adresem:

`http://<address>`
![Nginx pod adresem](images/8.%20Nginx%20pod%20adresem.png)

## Oczyszczanie środowiska

W celu zaoszczędzenia kredytów, należy usunąć wszystkie utworzone instancje.

Zatrzymywanie kontenera:

`az container stop`
![Zatrzymanie kontenera](images/9.%20Zatrzymanie%20kontenera.png)

Usunięcie kontenera:

`az container delete`
![Usunięcie kontenera](images/10.%20Usunięcie%20kontenera.png)

Grupę usuwa się poleceniem `az group delete`.

Powinno się sprawdzić czy wszystkie instancje zostały usunięte:

`az group list`
![Lista grup](images/11.%20Lista%20grup.png)

Jeżeli lista grup zasobów jest pusta, udało się przywrócić środowisko do stanu pierwotnego.