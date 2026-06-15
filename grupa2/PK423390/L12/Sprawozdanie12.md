# Sprawozdanie Lab 12 - Wdrażanie na zarządzalne kontenery w chmurze (Azure)

---

## 1. Przygotowanie obrazu na Docker Hub

Na bazie obrazu `apl:v2` z poprzednich zajęć (nginx z podmienioną stroną startową) otagowano i wypchnięto obraz do repozytorium Docker Hub.

```bash
docker tag apl:v2 madpapito/apl:v2
docker login
docker push madpapito/apl:v2
```

Logowanie do Docker Hub odbyło się metodą web-based login. Po uwierzytelnieniu wszystkie warstwy obrazu zostały pomyślnie wysłane do repozytorium `docker.io/madpapito/apl`.

![Wypchnięcie obrazu na Docker Hub](IMG/Zrzut%20ekranu%202026-06-12%20005845.png)


---

## 2. Uruchomienie Azure Cloud Shell

Zalogowano się do portalu Azure przy użyciu konta studenckiego. Uruchomiono Azure Cloud Shell w trybie Bash.

![Konfiguracja Cloud Shell - wybór subskrypcji](IMG/Zrzut%20ekranu%202026-06-12%20010154.png)

![Azure Cloud Shell uruchomiony](IMG/Zrzut%20ekranu%202026-06-12%20010245.png)

---

## 3. Rejestracja dostawców usług

Ze względu na świeżo aktywowaną subskrypcję studencką konieczne było ręczne zarejestrowanie dostawców usług.

```bash
az provider register --namespace Microsoft.CloudShell
az provider register --namespace Microsoft.ContainerInstance
az provider show -n Microsoft.ContainerInstance --query registrationState
```

![Rejestracja Microsoft.ContainerInstance - status Registered](IMG/Zrzut%20ekranu%202026-06-12%20010751.png)

---

## 4. Utworzenie grupy zasobów

```bash
az group create --name rg-pablo-apl --location francecentral
```

![Tworzenie grupy zasobów](IMG/Zrzut%20ekranu%202026-06-12%20010509.png)

---

## 5. Wdrożenie kontenera z Docker Hub

Wdrożono kontener z obrazu `madpapito/apl:v2` dostępnego na Docker Hub.

![Wdrożenie kontenera - komenda az container create](IMG/Zrzut%20ekranu%202026-06-12%20010902.png)

Azure automatycznie pobrał obraz z Docker Hub i uruchomił kontener. W odpowiedzi widoczny był adres publiczny:

```text
pablo-apl-12345.francecentral.azurecontainer.io
```

---

## 6. Weryfikacja działania kontenera

Sprawdzono stan kontenera:

![Stan kontenera - Running](IMG/Zrzut%20ekranu%202026-06-12%20011102.png)

---

## 7. Pobranie logów aplikacji

Logi potwierdziły poprawne uruchomienie serwera nginx - widoczny był komunikat `start worker processes` oraz informacja o wersji nginx 1.31.1 na Alpine Linux.

![Logi kontenera](IMG/Zrzut%20ekranu%202026-06-12%20011148.png)

---

## 8. Dostęp do usługi HTTP

Aplikacja była dostępna pod publicznym adresem DNS przydzielonym przez Azure:

```text
http://pablo-apl-12345.francecentral.azurecontainer.io
```

Działanie aplikacji zweryfikowano w przeglądarce internetowej.

![Aplikacja dostępna w przeglądarce](IMG/Zrzut%20ekranu%202026-06-12%20011205.png)

---

## 9. Usunięcie kontenera i grupy zasobów

Po zakończeniu testów usunięto kontener oraz grupę zasobów, aby uniknąć naliczania kosztów.

```bash
az container delete \
  --resource-group rg-pablo-apl \
  --name aci-pablo-apl \
  --yes

az group delete \
  --name rg-pablo-apl \
  --yes \
  --no-wait
```

Weryfikacja potwierdziła usunięcie grupy zasobów:

```bash
az group show --name rg-pablo-apl
```

```text
(ResourceGroupNotFound) Resource group 'rg-pablo-apl' could not be found.
```

![Usunięcie kontenera](IMG/Zrzut%20ekranu%202026-06-12%20011325.png)

![Usunięcie grupy zasobów](IMG/Zrzut%20ekranu%202026-06-12%20011333.png)

![Potwierdzenie braku grupy zasobów](IMG/Zrzut%20ekranu%202026-06-12%20011411.png)

---

## Wnioski

W ramach ćwiczenia pomyślnie wdrożono kontener Docker na platformę Microsoft Azure przy użyciu usługi Azure Container Instances. Wdrożenie bezpośrednio z Docker Hub nie wymagało tworzenia prywatnego rejestru w Azure. Usługa ACI znacząco upraszcza uruchamianie kontenerów w chmurze w porównaniu do konfiguracji pełnego klastra Kubernetes - wystarczy jedna komenda `az container create` bez zarządzania infrastrukturą. Po zakończeniu pracy wszystkie zasoby zostały usunięte, co zapobiegło niepotrzebnemu zużyciu kredytów studenckich.