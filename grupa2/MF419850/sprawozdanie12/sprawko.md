# Sprawozdanie

## Setup

Aktualna wesja kontenera na dockerhub:

![](1.png)

Po zarejestrowaniu dostawcy komendą:

az provider register --namespace Microsoft.ContainerInstance

![](2.png)

Status Registered potwierdza możliwość tworzenia instancji kontenerów Azure Container Instances.

Lista dostępnych lokacji do utworzenia grupy:

![](3.0.png)  

Utworzenie grupy zasobów rg-mf419850 w regionie polandcentral, dostępność regionu została potwierdzona w poprzednim kroku.

![](3.png)  

Utworzenie instancji kontenera z wykorzystaniem obrazu gafran/mf419850-web:v2 pobranego z Docker Hub.
Zawiera konfigurację publicznego adresu IP, nazwy DNS, parametrów zasobów (1 vCPU, 1 GB RAM) oraz systemu.

![](4.png)  

Potwierdzenie działania kontenera:

![](5.png)  

## Rezultat

Logi kontenera oraz adres strony:

![](6.0.png)

Przeprowadzone kroki pozwoliły na wyświetlenie strony pod publicznym adresem, sukces.

![](6.png)

## Czyszczenie zasobów zapobiegające wyczerpywaniu środków

![](7.png)