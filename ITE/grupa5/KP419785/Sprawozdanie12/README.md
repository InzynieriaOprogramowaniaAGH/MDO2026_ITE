# SPRAWOZDANIE 12
 
## Środowisko uruchomieniowe
 
- System operacyjny (maszyna lokalna): Ubuntu 24.04 LTS - maszyna wirtualna `devops`
- Metoda dostępu: Zdalna sesja przez SSH (użytkownik: `karro`)
- Silnik kontenerów: Docker 29.2.1
- Platforma chmurowa: Microsoft Azure (subskrypcja: Azure for Students)
- Narzędzie zarządzania: Azure Cloud Shell (Bash) + Azure CLI (`az`)
- Rejestr obrazów: Docker Hub (`karro28/portfinder-web`)
- Projekt: `portfinder-web`, obraz nginx z własną konfiguracją HTML (z poprzednich laboratoriów)

## 1. Przygotowanie kontenera
 
Użyto webowego flow logowania (`docker login`). Terminal wyświetlił jednorazowy kod urządzenia `QMSL-QDCW` i link do strony aktywacji:
 
```bash
docker login
```
 
![1](<img/Zrzut ekranu 2026-06-01 220444.png>)
 
Kod wprowadzono na stronie `login.docker.com/activate`:
 
![2](<img/Zrzut ekranu 2026-06-01 220423.png>)
 
Po potwierdzeniu tożsamości urządzenia na stronie Docker Device Confirmation:
 
![3](<img/Zrzut ekranu 2026-06-01 220456.png>)
 
Strona potwierdziła pomyślne połączenie urządzenia ("Your device is now connected"):
 
![4](<img/Zrzut ekranu 2026-06-01 220635.png>)
 
W terminalu pojawiło się potwierdzenie `Login Succeeded`. Ostrzeżenie o niezaszyfrowanych danych uwierzytelniających w `~/.docker/config.json` jest informacyjne, w środowisku produkcyjnym należałoby skonfigurować credential helper:
 
![5](<img/Zrzut ekranu 2026-06-01 220651.png>)
 
Obraz `portfinder-web:v2` z poprzednich laboratoriów (nginx z własną stroną HTML, wersja "v2 updated") otagowano nazwą użytkownika Docker Hub `karro28` i wypchnięto jako dwa tagi:
 
```bash
docker tag portfinder-web:v2 karro28/portfinder-web:v2
docker tag portfinder-web:v2 karro28/portfinder-web:latest
docker images | grep karro28
```
 
Obraz `b4cf95b67853` o rozmiarze 92.7 MB dostępny pod oboma tagami:
 
![6](<img/Zrzut ekranu 2026-06-01 223022.png>)
 
```bash
docker push karro28/portfinder-web:v2
docker push karro28/portfinder-web:latest
```
 
Push tagu `v2` przesłał wszystkie warstwy. Push tagu `latest` wskazał na te same warstwy (`Layer already exists`). Obraz jest identyczny, różnią się jedynie tagi:
 
![7](<img/Zrzut ekranu 2026-06-01 223202.png>)
 
Potwierdzono dostępność obrazu w publicznym repozytorium `karro28/portfinder-web` na Docker Hub. Tag `latest` widoczny jako ostatnio zaktualizowany:
 
![8](<img/Zrzut ekranu 2026-06-01 223259.png>)
 
## 2. Zapoznanie z platformą Azure
 
Zalogowano się do Azure Portal przy użyciu konta studenckiego AGH (`kipytel@student.agh.edu.pl`) z subskrypcją **Azure for Students**. Uruchomiono Azure Cloud Shell (Bash) bezpośrednio z poziomu portalu:
 
![9](<img/Zrzut ekranu 2026-06-01 230131.png>)
 
```bash
az account show
```
 
Wynik potwierdza aktywną subskrypcję "Azure for Students" przypisaną do konta AGH:
 
![10](<img/Zrzut ekranu 2026-06-01 230617.png>)
 
## 3. Wdrożenie kontenera na Azure
 
```bash
az group create --name KP419785-rg3 --location swedencentral
```
 
Początkowa próba wdrożenia w domyślnym regionie westeurope została odrzucona przez system. Mogło to być spowodowane odgórnymi restrykcjami dla studenckich subskrypcji w tym obciążonym centrum danych lub specyficznymi problemami z konfiguracją środowiska Nginx na poziomie platformy. Aby ominąć blokadę, aplikację z sukcesem uruchomiono w alternatywnym regionie swedencentral, co potwierdza status "provisioningState": "Succeeded".
 
![11](<img/Zrzut ekranu 2026-06-01 231309.png>)
 
```bash
az container create --resource-group KP419785-rg3 --name portfinder-kp419785 --image karro28/portfinder-web:latest --dns-name-label portfinder-kp419785-sweden --ports 80 --os-type Linux --cpu 1 --memory 1
```
 
Przed wykonaniem komendy zweryfikowano stan dostawcy usług kontenerowych:
 
```bash
az provider show -n Microsoft.ContainerInstance --query "registrationState"
```
 
Stan `"Registering"` wskazał, że dostawca był jeszcze w trakcie rejestracji. Mimo to polecenie `az container create` zakończyło się sukcesem. Zwrócony JSON zawiera `"state": "Running"` oraz zdarzenie `"Pulling"` potwierdzające pobranie obrazu z Docker Hub:
 
![12](<img/Zrzut ekranu 2026-06-01 231408.png>)
 
```bash
az container show --resource-group KP419785-rg3 --name portfinder-kp419785 --query "{Status:instanceView.state, FQDN:ipAddress.fqdn, IP:ipAddress.ip}" --output table
```
 
Logi nginx potwierdzają poprawne uruchomienie serwera. Widoczna inicjalizacja konfiguracji, uruchomienie nginx v1.31.1 na Alpine Linux z jądrem (środowisko Azure):
 
![13](<img/Zrzut ekranu 2026-06-01 231641.png>)
 
Pobrano FQDN przez zapytanie i przetestowano dostęp przez curl:
 
```bash
FQDN=$(az container show  --resource-group KP419785-rg3 --name portfinder-kp419785 --query "ipAddress.fqdn" --output tsv)
curl http://$FQDN
```
 
Serwer zwrócił poprawną stronę HTML z wersją v2 obrazu:
 
![14](<img/Zrzut ekranu 2026-06-01 231712.png>)
 
Weryfikacja dostępu przez bezpośrednie użycie FQDN:
 
```bash
curl http://portfinder-kp419785-sweden.swedencentral.azurecontainer.io
```
 
![15](<img/Zrzut ekranu 2026-06-01 231844.png>)
 
Obie metody potwierdzają, że kontener pracuje i serwuje aplikację HTTP, strona "Portfinder Deploy - KP419785 v2" jest dostępna publicznie pod adresem DNS przypisanym przez Azure.
 
## 4. Zatrzymanie i usunięcie zasobów
 
```bash
az container stop --resource-group KP419785-rg3 --name portfinder-kp419785
 
az group delete --name KP419785-rg3 --yes --no-wait
```
 
Flaga `--no-wait` powoduje natychmiastowy powrót do promptu. Usunięcie odbywa się asynchronicznie w tle:
 
![16](<img/Zrzut ekranu 2026-06-01 231957.png>)
 
Bezpośrednio po wydaniu komendy `az group show` zwrócił stan `"provisioningState": "Deleting"`. Po chwili powtórzone zapytanie zwróciło błąd `ResourceGroupNotFound`, potwierdzając całkowite usunięcie grupy zasobów:
 
```bash
az group show --name KP419785-rg3
# → "provisioningState": "Deleting"
 
az group show --name KP419785-rg3
# → (ResourceGroupNotFound) Resource group 'KP419785-rg3' could not be found.
```
 
![17](<img/Zrzut ekranu 2026-06-01 232016.png>)
 
## Podsumowanie
 
### Docker Hub jako rejestr obrazów
 
Docker Hub pozwala na publiczne udostępnienie obrazu bez konieczności tworzenia prywatnego rejestru w Azure. Wystarczy otagować obraz nazwą użytkownika i wykonać `docker push`. Azure Container Instances pobiera obraz bezpośrednio z Docker Hub podczas tworzenia kontenera, widoczne w Events jako zdarzenie `"Pulling"`.
 
### Azure Container Instances
 
ACI to usługa bezserwerowa, nie wymaga konfiguracji klastra ani węzłów (w przeciwieństwie do Kubernetes). Wdrożenie sprowadza się do jednej komendy `az container create`. Kontener otrzymuje publiczny adres IP i opcjonalną nazwę DNS. Usługa jest rozliczana per sekunda, co czyni ją odpowiednią do krótkich zadań lub demonstracji.
 
### Zarządzanie kosztami
 
Kluczową praktyką jest usunięcie całej Resource Group po zakończeniu pracy, a nie tylko kontenera. `az group delete --yes --no-wait` usuwa wszystkie zasoby w grupie asynchronicznie. Weryfikację usunięcia zapewnia `az group show` zwracające `ResourceGroupNotFound`. Zatrzymanie kontenera (`az container stop`) przed usunięciem grupy jest dobrą praktyką, ale samo usunięcie grupy jest operacją wystarczającą.
 


 