# Wdrażanie na zarządzalne kontenery w chmurze (Azure)

Tworzymy konto na platformie Docker Hub, aby móc przechowywać nasze obrazy kontenerów. Następnie tworzymy zasoby w Azure, takie jak grupy zasobów, rejestry kontenerów i usługi zarządzane, które umożliwią nam wdrażanie naszych aplikacji w kontenerach.

<br/>
<br/>

## Przygotowanie kontenera

Sprawdzamy czy obraz z naszą stroną www został prawidłowo zbudowany i czy działa lokalnie.

```bash
docker build -t my-portfolio:v1 .
docker images
```

![Obraz kontenera](<./img/Screenshot 2026-06-18 at 12.39.51.png>)

```bash
docker run --rm -d -p 8080:80 --name test my-portfolio:v1
curl http://localhost:8080
```

![Wynik działania kontenera](<./img/Screenshot 2026-06-18 at 12.43.03.png>)

Wszystko jest w porządku, więc możemy dodać ten obraz do Docker Hub, aby był dostępny w Azure.

Logujemy się do Docker Hub i przesyłamy nasz obraz

```bash
docker login
docker info
```

![Logowanie do Docker Hub](<./img/Screenshot 2026-06-18 at 12.50.09.png>)

Tagujemy obraz i przesyłamy go do Docker Hub

```bash
docker tag my-portfolio:v1 m4rch3w44a/my-portfolio:v1

docker push m4rch3w44a/my-portfolio:v1
```

![Tagowanie obrazu](<./img/Screenshot 2026-06-18 at 12.54.25.png>)

Są dwie różne nazwy ale to samo id, obraz został poprawnie przesłany do Docker Hub.

![Wynik przesyłania obrazu](<./img/Screenshot 2026-06-18 at 12.55.27.png>)

<br/>
<br/>

## Praca w Azure

### Uruchomienie Azure Cloud Shell

Sprawdzamy czy mamy dostęp do Azure Cloud Shell i patrzymy czy mamy aktywny plan subskrypcji.

![Uruchomienie Azure Cloud Shell](<./img/Screenshot 2026-06-18 at 13.18.31.png>)

### Utworzenie Resource Group

```bash
az group create --name rg-my-app --location westeurope
```

![Utworzenie Resource Group](<./img/Screenshot 2026-06-18 at 13.20.41.png>)

### Rejestracja dostawcy Container Instances

Nas†epnie musimy zarejestrować dostawcę Container Instances, aby móc korzystać z tej usługi w naszej subskrypcji. Rejestracja chwilę trwa, więc musimy poczekać na jej zakończenie.

```bash
az provider register --namespace Microsoft.ContainerInstance
```

![Rejestracja dostawcy Container Instances](<./img/Screenshot 2026-06-18 at 13.29.03.png>)

### Wdrożenie kontenera w Azure

Teraz możemy wdrożyć nasz kontener w Azure. Używamy polecenia `az container create`, aby utworzyć instancję kontenera z naszym obrazem z Docker Hub.

```bash
az container create \
    --resource-group rg-my-app \
    --name my-app-container \
    --image m4rch3w44a/my-portfolio:v1 \
    --dns-name-label my-app-m4rch3w44a \
    --ports 80 \
    --ip-address Public \
    --cpu 1 \
    --memory 1 \
    --os-type Linux \
    --location austriaeast
```

![Wdrożenie kontenera w Azure](<./img/Screenshot 2026-06-18 at 13.33.58.png>)

![Wdrożenie kontenera w Azure](<./img/Screenshot 2026-06-18 at 13.35.04.png>)

Jak widać wszystko działa poprawnie, nasz kontener został wdrożony w Azure i jest dostępny pod adresem `http://my-app-m4rch3w44a.austriaeast.azurecontainer.io`.

### Weryfikacja działania kontenera

Napotkałem pewnien problem, który wynikał z tego, że zbudowałem obraz kontenera na systemie MacOS, a następnie próbowałem uruchomić go w Azure, który używa systemu Linux. W związku z tym musiałem przebudować obraz, żeby korzystał z archtektury amd64, a nie arm64. Po przebudowaniu obrazu i ponownym wdrożeniu kontenera w Azure wszystko działa poprawnie.

Wyświetlamy adres ip i dns name naszego kontenera, aby móc się do niego dostać.

```bash
az container show \
    --resource-group rg-my-app \
    --name my-app-container \
    --query "{name:name, state:instanceView.state, ip:ipAddress.ip, fqdn:ipAddress.fqdn}" \
    --output table
```

![Weryfikacja działania kontenera](<./img/Screenshot 2026-06-18 at 14.18.19.png>)

Teraz sprawdzamy czy nasza strona jest dostępna pod adresem ip i dns.

![Weryfikacja działania kontenera](<./img/Screenshot 2026-06-18 at 14.18.37.png>)

![Weryfikacja działania kontenera](<./img/Screenshot 2026-06-18 at 14.17.39.png>)

### Analiza logów kontenera

![Analiza logów kontenera](<./img/Screenshot 2026-06-18 at 14.22.20.png>)

Logi pokazują co kontener robi w środku, czy się uruchomił poprawnie, czy są błędy, czy ktoś się połączył.

Patrząc na rekord zaczynający się od `GET / HTTP/1.1" 200` widać, że ktoś (my) połączyliśmy się z naszą stroną i pobraliśmy ją poprawnie, co było widać w przeglądarce.

### Usunięcie zasobów

Najpierw usuwamy kontenery.

```bash
az container delete \
    --resource-group rg-my-app \
    --name my-app-container \
    --yes
```

![Usunięcie zasobów](<./img/Screenshot 2026-06-18 at 14.24.57.png>)

Następnie usuwamy grupę zasobów, która zawiera wszystkie zasoby, które utworzyliśmy w tym laboratorium.

```bash
az group delete \
    --name rg-my-app \
    --yes
```

![Usunięcie zasobów](<./img/Screenshot 2026-06-18 at 14.27.41.png>)
