# Sprawozdanie Lab12, Tomasz Kamiński


## Przygotowanie kontenera


![](./img/image4.png)

![](./img/image3.png)

Wykorzystano obraz v2 z poprzednich zajęć i wypchnięto go na repozytorium dockerhub


## Azure

![](./img/image2.png)


Uruchomienie Azure Cloud Shell w trybie Bash

![](./img/image5.png)


## Utworzenie grupy zasobów 

![](./img/image6.png)


Podczas prób wdrożenia w regionach northeurope, polandcentral czy francecentral system Azure zwracał błąd odmowy dostępu, dopiero po wykorzystaniu polecnia ``` az policy assignment list --disable-scope-strict-match --query "[?name=='sys.regionrestriction'].parameters" --output json ``` można było określić prawidłową i w pełni autoryzowaną listę regionów geograficznych przypisanych do posiadanej subskrypcji studenckiej.

![](./img/image8.png)



Po skorygowaniu lokalizacji na dozwolony region swedencentral, ponowne wywołanie polecenia ```az container create```  zakończyło się sukcesem. Utworzono instancje kontera z wykorzystaniem obrazu tkaminskiagh/app:v2 

![](./img/image9.png)



## Wykazanie stanu pracy kontenera 

![](./img/image12.png)



## Pobranie logów aplikacji 

![](./img/image11.png)


## Dostęp do usługi HTTP 


Wcześniejsze korki umożliwiły wyświetlnie strony pod publicznym adresem DNS przydzielonym przez Azure;

```http://tomasz-app-lab-agh-2026.swedencentral.azurecontainer.io/ ```

![](./img/image13.png)


## Usunięcie kontenera i grupy zasobów 

Usunięcie kontenera:

![](./img/image14.png)

Usuniecie grupy:

![](./img/image15.png)

Brak dostępnych grup:

![](./img/image16.png)

