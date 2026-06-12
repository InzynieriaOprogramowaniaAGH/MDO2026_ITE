# Sprawozdanie laboratorium nr 12
**Autor:** Aleksandra Duda, grupa 2

## Cel
Celem laboratorium było zapoznanie się z wdrażaniem na zarządzalne kontenery w chmurze Azure.

--------------------------------------------------------------------------------------

## Zadania do wykonania

### Przygotowanie kontenera
 - Proszę upewnić się, że dysponuje się własnym kontenerem z aplikacją
 - Proszę zaktualizować wersję kontenera obecną na Docker Hub

Kontener znajduje się na DockerHub w repozytorium publicznym:
![alt text](image.png)
 
### Zapoznanie z platformą
Zalogowałam się na konto azure:
![alt text](image-1.png)
Na maszynie wirtualnej zainstalowalam Azure CLI i zalogowałam się do konta azure (az login --use-device-code):
![alt text](image-3.png)
![alt text](image-4.png)
![alt text](image-2.png)

### Zadanie do wykonania
 1. Utwórz własny resource group
 Najpierw utworzyłam zmienne potrzebne do wykonania ćwiczenia (dobra praktyka devopsowa):
 ![alt text](image-5.png)
 Stworzyłam resource group:
 ![alt text](image-6.png)

 2. Wdróż swój kontener z Docker Hub w swoim Azure
 Przy pierwszej próbie utworzenia kontenera otrzymalam błąd:
 ![alt text](image-7.png)
 Wskazywał on na brak możliwości użycia regionu polskiego w kontenerze, dlatego zmieniłam region na Europę. Jednak problem caly czas sie pojawiał. Zmieniłam obraz na httpd, przetestowałam różne lokacje, jednak nic nie pomogło. Przeniosłam więc pracę do terminala bash w portal.azure, jednak tam, mimo zastosowania komendy 'az provider register --namespace Microsoft.ContainerInstance' błąd nadal się pojawiał:
![alt text](image-8.png)

Sprawdziłam więc dostępne lokacje do utworzenia kontenera:
![alt text](image-9.png)
Okazało się, że na liście dostępnych lokalizacji nie ma ani Polski, ani Europy ani USA. Do utworzenia grupy i kontenera wybrałam więc Szwecję:
![alt text](image-10.png)
![alt text](image-11.png)
Status "succeeded" świadczy o tym, że kontener uruchomił się prawidłowo.

 3. Wykaż, że kontener został uruchomiony i pracuje, pobierz logi, przedstaw metodę dostępu do serwowanej usługi HTTP
![alt text](image-14.png)
![alt text](image-13.png)
![alt text](image-12.png)

 4. Zatrzymałam i usunęłam kontener i grupę:
![alt text](image-15.png)
![alt text](image-16.png)

--------------------------------------------------------------------------------------

 ## Wnioski
Podczas zajęć laboratoryjnych nauczyłam się wdrażania na platformie azure, wykorzystując resource grupy i kontenery z aplikacją z poprzednich zajęć. Bardzo istotna przy wdrażaniu kontenerów jest odpowiednia lokalizacja oraz usunięcie zasobów po wykonanym ćwiczeniu, ze względu na płatne tokeny.