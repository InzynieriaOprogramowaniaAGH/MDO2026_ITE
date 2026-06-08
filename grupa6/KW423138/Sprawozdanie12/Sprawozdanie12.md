# Sprawozdanie - zajęcia 12

## Przygotowanie kontenera

Przed przystąpieniem do ćwiczenia, zaktualizowałem obecną wersję kontenera na moim koncie Docker Hub:

![1](obrazyLab12/0.png)

## Zapoznanie się z dokumentacją Azure, odblokowanie konta studenckiego

![2](obrazyLab12/azure.png)

## Zadania do wykonania

### Utworzenie własnego resource group:

![3](obrazyLab12/1.png)
![4](obrazyLab12/2.png)

Grupa została utworzona w regionie `germanywestcentral`, ponieważ subskrybcja studencka pozwalała tylko w określonych regionach tworzyć zasoby.

### Wdrożenie kontenera z Docker Hub do Azure

![5](obrazyLab12/4.png)
![6](obrazyLab12/5.png)

### Pokazanie działania kontenera, logi

![7](obrazyLab12/7.png)
![8](obrazyLab12/3.png)
![9](obrazyLab12/6.png)
![10](obrazyLab12/8.png)

### Usunięcie kontenera i grupy

Po wykonaniu ćwiczenia usunąłem utworzony kontener i resorce group:

```
az container delete \
    --resource-group rg-lab12 \
    --name kontenerkpw22 \
    --yes
```

```
az group delete --name rg-lab12 --yes --no-wait
```

#### Sprawdzenie czy zasoby się usunęły:

![11](obrazyLab12/usun.png)

Nic się nie wyświetla, więc zasoby usunęły się poprawnie.
