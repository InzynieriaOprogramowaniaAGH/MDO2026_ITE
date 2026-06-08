# Sprawozdanie 12 - Wdrażanie na zarządzalne kontenery w chmurze (Azure)

**Imię i Nazwisko:** Franciszek Tokarek  
**Numer albumu:** FT422048  

---

## 1. Przygotowanie kontenera i Docker Hub
Obraz aplikacji został poprawnie przygotowany, zaktualizowany pod architekturę chmurową i wypchnięty do publicznego repozytorium Docker Hub:
* **Repozytorium:** `ft87123885/moja-apka:v3`

## 2. Procedura wdrożenia w Azure Container Instances (ACI)
W celu uruchomienia kontenera utworzono grupę zasobów, a następnie wdrożono kontener przy użyciu Azure CLI (`az cli`):

```bash
# Utworzenie grupy zasobów
az group create --name RG-FT422048-US --location westeurope

# Uruchomienie kontenera w chmurze
az container create --resource-group RG-FT422048-US --name web-kontener --image ft87123885/moja-apka:v3 --ip-address public --ports 80 --location westeurope --dns-name-label apka-ft422048 --os-type Linux --cpu 1 --memory 1.5
```

## 3. Weryfikacja działania i logi usługi
Potwierdzenie poprawnego wdrożenia oraz statusu `Succeeded` pobrane za pomocą komendy:
```bash
az container show --resource-group RG-FT422048-US --name web-kontener --query "{IP:ipAddress.ip, FQDN:ipAddress.fqdn, Status:provisioningState}" --output table
```
*Dowód wdrożenia znajduje się na zrzucie ekranu `lab12_3.png`.*

Pobranie logów serwera HTTP potwierdzających obsługę żądań sieciowych:
```bash
az container logs --resource-group RG-FT422048-US --name web-kontener
```
*Logi serwera przedstawiono na zrzucie ekranu `lab12_4.png`.*

## 4. Usunięcie zasobów
Po zakończeniu testów i zebraniu dowodów, cała grupa zasobów została usunięta w celu zatrzymania naliczania kosztów subskrypcji studenckiej:
```bash
az group delete --name RG-FT422048-US --yes
```
