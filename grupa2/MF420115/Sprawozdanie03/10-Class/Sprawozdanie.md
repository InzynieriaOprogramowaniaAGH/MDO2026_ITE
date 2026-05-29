Autor: Maciej Fraś 

Data: 29 Maja 2026 r.

Środowisko: Ubuntu 24.04.4 LTS (Virtual Machine / Hyper-V), Visual Studio Code (VSC)

1. Cel zajęć
Wdrażanie na zarządzalne kontenery: Kubernetes

2. Instalacja klastra i mitygacja ograniczeń sprzętowych
W celu optymalizacji ograniczeń pamięciowych maszyny wirtualnej, klaster minikube został pomyślnie zainicjalizowany z jawnym przydziałem 1900 MiB RAM oraz 2 rdzeni procesora.

![Instalacja klastra](ss/uruchominieKlastra.png)

![](ss/nodes.png)

3. Interfejs komunikacyjny (API SERVER)
Wywołano usługę panelu zarządzania, przekierowania portów oraz łączności z punktami końcowymi API serwera klastra za pośrednictwem  proxy.

![Podgląd struktury JSON mapowania punktów końcowych](ss/k8sdashboard.png)

4. Wdrażanie aplikacji w architekturze jednopodowej
Wdrożono pojedynczy kontener aplikacji sieciowej opartej na obrazie nginx:alpine na porcie 80. Sprawdzono status procesu tworzenia izolowanej jednostki Pod.

![Monitorowanie procesu pobierania i wdrażania zasobów aplikacji](ss/wdrozeniepodu.png)

Ruch sieciowy przekierowano na wolny port hosta 8085. Test komunikacji zrealizowano z poziomu przeglądarki, uzyskując bezpośredni dostęp do funkcjonalności serwera:

![Wyświetlenie domyślnej strony powitalnej serwera aplikacji po poprawnym trasowaniu portów.](ss/welcomeToNginx.png)

5. Deployment
Stworzono aautomatyczny plik deployment w formacie yaml.Architekturę aplikacji wyskalowano do 4 niezależnych replik.

![Plik yaml](ss/deploymentYaml.png)

![Wyświetlenie 4 aktywnych Podów) utrzymujących status operacyjny](ss/kubernetesReplicas.png)

6. Oczyszczenie środowiska
Usunięcie zasobów testowych w celu zwolnienia pamięci:

![Usuniecie Zasobów](ss/usuniecieZasobow.png)