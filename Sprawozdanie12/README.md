# Wdrażanie na zarządzalne kontenery w chmurze (Azure)

## Opis laboratorium

Laboratorium obejmuje wdrożenie własnego kontenera Docker z Docker Hub na platformę **Azure Container Instances (ACI)**. Zadanie obejmuje utworzenie resource group, wdrożenie kontenera, weryfikację działania serwisu HTTP, pobranie logów oraz poprawne usunięcie zasobów.

---

## Środowisko

- **Platforma:** Microsoft Azure (konto studenckie Azure for Students)
- **Usługa:** Azure Container Instances (ACI)
- **Rejestr obrazów:** Docker Hub (`szyszon26/myapp`)
- **Region:** `francecentral`
- **Narzędzie:** Azure Cloud Shell (Bash)

---

## 1. Przygotowanie kontenera

Obraz użyty w laboratorium pochodzi z poprzednich zajęć (Kubernetes Lab). Oparty jest na `httpd:2.4-alpine` z własną stroną HTML.

Logowanie do Docker Hub i wypychanie obrazu:

```bash
docker login
docker tag myapp:v1 szyszon26/myapp:v1
docker push szyszon26/myapp:v1
```

> **Screenshot:** `przygotowanie.png` — docker images oraz docker push obrazu na Docker Hub

Dostępne wersje obrazu na Docker Hub:

| Obraz | Tag | Opis |
|-------|-----|------|
| `szyszon26/myapp` | `v1` | Działający serwer HTTP — "Wersja 1.0" |
| `szyszon26/myapp` | `v2` | Działający serwer HTTP — "Wersja 2.0" |
| `szyszon26/myapp` | `broken` | Kontener kończy się błędem (CrashLoopBackOff) |

---

## 2. Utworzenie Resource Group

```bash
az group create \
  --name myResourceGroup \
  --location francecentral
```

Wynik: `"provisioningState": "Succeeded"`

> **Screenshot:** `utworzeniegrupy.png` — potwierdzenie utworzenia resource group

---

## 3. Wdrożenie kontenera z Docker Hub

```bash
az container create \
  --resource-group myResourceGroup \
  --name mycontainer \
  --image szyszon26/myapp:v1 \
  --dns-name-label szyszon26-agh \
  --ports 80 \
  --ip-address public \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --location francecentral
```

Kontener został wdrożony z publicznym adresem IP i nazwą DNS.

---

## 4. Weryfikacja działania kontenera

### Status kontenera

```bash
az container show \
  --resource-group myResourceGroup \
  --name mycontainer \
  --query "{Status:instanceView.state, FQDN:ipAddress.fqdn, IP:ipAddress.ip}" \
  --output table
```

Wynik:

| Status | FQDN | IP |
|--------|------|----|
| Running | szyszon26-agh.francecentral.azurecontainer.io | 4.176.23.16 |

### Logi kontenera

```bash
az container logs \
  --resource-group myResourceGroup \
  --name mycontainer
```

Wynik logów:
```
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1
[Mon Jun 08 15:22:21.551367 2026] [mpm_event:notice] Apache/2.4.67 (Unix) configured -- resuming normal operations
[Mon Jun 08 15:22:21.551444 2026] [core:notice] Command line: 'httpd -D FOREGROUND'
```

> **Screenshot:** `check.png` — status Running, FQDN, IP oraz logi kontenera

### Dostęp do serwisu HTTP

Metoda dostępu: publiczny adres DNS przypisany przy tworzeniu kontenera.

URL: `http://szyszon26-agh.francecentral.azurecontainer.io`

```bash
curl http://$(az container show \
  --resource-group myResourceGroup \
  --name mycontainer \
  --query "ipAddress.fqdn" \
  --output tsv)
```

Odpowiedź serwera:
```html
<html><body style="background:#2196F3;color:white;..."><h1>Wersja 1.0</h1><p>Kubernetes Lab 2</p></body></html>
```

---

## 5. Zatrzymanie i usunięcie zasobów

```bash
# Zatrzymanie kontenera
az container stop \
  --resource-group myResourceGroup \
  --name mycontainer

# Usunięcie kontenera
az container delete \
  --resource-group myResourceGroup \
  --name mycontainer \
  --yes

# Usunięcie resource group
az group delete \
  --name myResourceGroup \
  --yes

# Potwierdzenie
az group list --output table
```

> **Screenshot:** `sprzatanie.png` — usunięcie kontenera i resource group, pusta lista grup

---

## Uwagi

- Konto studenckie AGH ma politykę blokującą część regionów dla ACI. Region `francecentral` okazał się działający.
- Przed wdrożeniem konieczna była rejestracja providera: `az provider register --namespace Microsoft.ContainerInstance`
- Parametr `--ip-address public` jest wymagany do uzyskania publicznego FQDN.
- Usunięcie resource group jest krytyczne — zatrzymuje naliczanie kosztów.
